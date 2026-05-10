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

var forward: Site
var back: Site
var counterclockwise: Site
var clockwise: Site
var sites: Array[Site]


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
	if !(abs(coord.x) > 1 or abs(coord.y) > 1): return
	
	var l = min(abs(coord.x), abs(coord.y))
	var x = sign(coord.x - sign(coord.x) * l)
	var y = sign(coord.y - sign(coord.y) * l)
	var direction = Vector2i(x, y)
	var windrose = Catalog.direction_to_windrose[direction]
	sector = horde.windrose_to_sector[windrose]
	
	match windrose:
		Bozo.Windrose.N:
			if sector.index_to_row.has(coord.y):
				row = sector.index_to_row[coord.y]
			col = sector.index_to_col[coord.x]
		Bozo.Windrose.E:
			if sector.index_to_row.has(coord.x):
				row = sector.index_to_row[coord.x]
			col = sector.index_to_col[coord.y]
		Bozo.Windrose.S:
			if sector.index_to_row.has(coord.y):
				row = sector.index_to_row[coord.y]
			col = sector.index_to_col[coord.x]
		Bozo.Windrose.W:
			if sector.index_to_row.has(coord.x):
				row = sector.index_to_row[coord.x]
			col = sector.index_to_col[coord.y]
	
	if row == null or col == null: return
	col.sites.append(self)
	row.sites.append(self)
	ring = abs(row.index)

func is_occupied() -> bool:
	return horde.site_to_insect.has(self)


func init_sites() -> void:
	init_forward()
	init_back()
	init_sides()

func init_forward() -> void:
	forward = null
	if col == null: return
	var id = col.sites.find(self)
	if id != -1 and id < col.sites.size() - 1:
		forward = col.sites[id + 1]
		sites.append(forward)

func init_back() -> void:
	back = null
	if col == null: return
	var id = col.sites.find(self)
	if id > 0:
		back = col.sites[id - 1]
		sites.append(back)

func init_sides() -> void:
	#return
	counterclockwise = null
	clockwise = null
	if col == null: return
	var id = col.sites.find(self)

	var next_col = col.clockwise_to_col[true]
	if next_col != null:
		if next_col.sites.size() > id:
			clockwise = next_col.sites[id]
			sites.append(clockwise)
	
	var previous_col = col.clockwise_to_col[false]
	if previous_col != null:
		if previous_col.sites.size() > id:
			counterclockwise = previous_col.sites[id]
			sites.append(counterclockwise)

#func get_align(site: Site) -> Site:
	#var col = site.col
	#if col == null or col.index == 0: return null
#
	#var center_col = col.sector.index_to_col.get(0)
	#if center_col == null: return null
#
	#var index = clamp(col.sites.find(site), 0, center_col.sites.size() - 1)
	#return center_col.sites[index]
