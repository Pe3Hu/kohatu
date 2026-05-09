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


func setup(horde_: Horde, windrose_: Bozo.Windrose) -> void:
	horde = horde_
	windrose = windrose_
	
	init_cols()
	init_rows()

func init_cols() -> void:
	for _i in range(-Catalog.HORDE_MAX_RING + 1, Catalog.HORDE_MAX_RING, 1):
		add_col(_i)

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
