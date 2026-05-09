extends Area2D
class_name Site


var horde: Horde
var coord: Vector2i
var index: int:
	set(value_):
		index = value_
		%IndexLabel.text = str(index)

var sector: Sector
var diagonal: Diagonal
var col: Col
var row: Row

var ring: int


func setup(horde_: Horde, coord_: Vector2i) -> void:
	horde = horde_
	coord = coord_
	
	index = horde.sites.size()
	position = horde.map_to_local(coord)
	
	join_diagonal()
	join_sector()

func join_diagonal() -> void:
	if abs(coord.x) != abs(coord.y): return
	if abs(coord.x) <= 1: return
	var direction = coord / abs(coord.x)
	var windrose = Catalog.direction_to_windrose[direction]
	diagonal = horde.windrose_to_diagonal[windrose]
	diagonal.sites.append(self)

func join_sector() -> void:
	if diagonal != null: return
	if abs(coord.x) <= 1: return
	
	var l = min(abs(coord.x), abs(coord.y))
	var x = sign(coord.x - sign(coord.x) * l)
	var y = sign(coord.y - sign(coord.y) * l)
	var direction = Vector2i(x, y)
	var windrose = Catalog.direction_to_windrose[direction]
	sector = horde.windrose_to_sector[windrose]
	
	match windrose:
		Bozo.Windrose.N:
			row = sector.index_to_row[coord.y]
			col = sector.index_to_col[coord.x]
		Bozo.Windrose.E:
			row = sector.index_to_row[coord.x]
			col = sector.index_to_col[coord.y]
		Bozo.Windrose.S:
			row = sector.index_to_row[coord.y]
			col = sector.index_to_col[coord.x]
		Bozo.Windrose.W:
			row = sector.index_to_row[coord.x]
			col = sector.index_to_col[coord.y]
	
	col.sites.append(self)
	row.sites.append(self)
	ring = abs(row.index)
