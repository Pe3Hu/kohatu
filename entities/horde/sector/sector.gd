extends Node2D
class_name Sector


@export var row_scene: PackedScene
@export var col_scene: PackedScene

var horde: Horde
var windrose: Bozo.Windrose

var cols: Array[Col]
var rows: Array[Row]

var index_to_col: Dictionary
var index_to_row: Dictionary

var diagonal_to_sector: Dictionary

var population: int = 0
var max_capacity: int


func setup(horde_: Horde, windrose_: Bozo.Windrose) -> void:
	horde = horde_
	windrose = windrose_
	
	init_cols()
	init_rows()
	
	max_capacity = 0
	
	for col in cols:
		max_capacity += col.sites.size()

func init_cols() -> void:
	for _i in range(-Catalog.HORDE_MAX_RING + 1, Catalog.HORDE_MAX_RING, 1):
		add_col(_i)
	
	resort_cols()

func init_rows() -> void:
	var _sign = 1
	
	if windrose == Bozo.Windrose.N or windrose == Bozo.Windrose.W:
		_sign = -1
	
	for _i in range(2, Catalog.HORDE_MAX_RING + 1, 1):
		add_row(_i * _sign)

func add_col(index_: int) -> void:
	var col = col_scene.instantiate()
	col.setup(self, index_)
	%Cols.add_child(col)
	cols.append(col)
	index_to_col[index_] = col

func add_row(index_: int) -> void:
	var row = row_scene.instantiate()
	row.setup(self, index_)
	%Rows.add_child(row)
	rows.append(row)
	index_to_row[index_] = row

func resort_cols() -> void:
	if windrose == Bozo.Windrose.N or windrose == Bozo.Windrose.E: return
	cols.sort_custom(func (a, b): return a.index > b.index)
	

func init_line_neighbours() -> void:
	init_row_neighbours()
	init_col_neighbours()
	
func init_row_neighbours() -> void:
	for _i in range(0, rows.size() - 1, 1):
		var previous_row = rows[_i + 1]
		var next_row = rows[_i]
		next_row.promotion_to_row[false] = previous_row
		previous_row.promotion_to_row[true] = next_row
	
func init_col_neighbours() -> void:
	for _i in range(0, cols.size() - 1, 1):
		var previous_col = cols[_i]
		var next_col = cols[_i + 1]
		next_col.clockwise_to_col[false] = previous_col
		previous_col.clockwise_to_col[true] = next_col

func has_free_columns() -> bool:
	for col in cols:
		if !col.sites.is_empty():
			var occupied = 0
			
			for site in col.sites:
				if horde.site_to_insect.has(site):
					occupied += 1
			
			if occupied < col.sites.size():
				return true

	return false
