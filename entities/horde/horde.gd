extends TileMapLayer
class_name Horde


var ring_to_coord: Dictionary
var coord_to_ring: Dictionary
var coord_to_windrose: Dictionary
var windrose_to_coord: Dictionary

var spawn_coords: Array[Vector2i]
var occupied_coords: Array[Vector2i]
var detained_coords: Array[Vector2i]


func _ready() -> void:
	init_insects()
	spawn_insects()
	horde_approach()

func init_insects() -> void:
	for windrose in Catalog.windrose_to_direction.keys():
		windrose_to_coord[windrose] = []
	
	for _y in range(-Catalog.HORDE_MAX_RING, Catalog.HORDE_MAX_RING + 1, 1):
		for _x in range(-Catalog.HORDE_MAX_RING, Catalog.HORDE_MAX_RING + 1, 1):
			var coord = Vector2i(_x, _y)
			var ring = max(abs(_y), abs(_x))
			
			if !ring_to_coord.has(ring):
				ring_to_coord[ring] = []
			
			ring_to_coord[ring].append(coord)
			coord_to_ring[coord] = ring
			var windrose = null
			
			if is_diagonal(coord):
				if abs(_x) != 0:
					var direction = coord / abs(_x)
					windrose = Catalog.direction_to_windrose[direction]
			else:
				var l = min(abs(_x), abs(_y))
				var x = sign(_x - sign(_x) * l)
				var y = sign(_y - sign(_y) * l)
				var direction = Vector2i(x, y)
				windrose = Catalog.direction_to_windrose[direction]
			
			if windrose != null:
				coord_to_windrose[coord] = windrose
				windrose_to_coord[windrose].append(coord)
	
	for windrose in Catalog.orthogonal_windroses:
		var max_ring_coords = ring_to_coord[Catalog.HORDE_MAX_RING]
		max_ring_coords = max_ring_coords.filter(func (a): return windrose_to_coord[windrose].has(a))
		#for coord in windrose_to_coord[windrose]:
		#	var ring = coord_to_ring[coord]
		#	if ring > 1:
		#		set_cell(coord, 0, Catalog.windrose_to_palette[windrose])
		var coord = max_ring_coords[Catalog.HORDE_MAX_RING - 1]
		spawn_coords.append(coord)

func spawn_insects() -> void:
	for _i in Catalog.STARTER_HORDE_INSECT_COUNT:
		spawn_insect()

func spawn_insect() -> void:
	var coord = spawn_coords.pick_random()
	var windrose = coord_to_windrose[coord]
	set_cell(coord, 0, Catalog.windrose_to_palette[windrose])
	update_spawn_coord(coord)

func update_spawn_coord(coord_: Vector2i) -> void:
	spawn_coords.erase(coord_)
	occupied_coords.append(coord_)
	var windrose = coord_to_windrose[coord_]
	
	for direction in Catalog.windrose_to_neighbour[windrose]:
		var neighbour_coord = coord_ + direction
		
		if !is_diagonal(neighbour_coord):
			if !occupied_coords.has(neighbour_coord):
				spawn_coords.append(neighbour_coord)

func horde_approach() -> void:
	for _j in Catalog.HORDE_MAX_RING - 2:
		for _i in range(occupied_coords.size()-1, -1, -1):
			var coord = occupied_coords[_i]
			insect_approach(coord)
		
		release_detained_coords()

func insect_approach(coord_: Vector2i) -> void:
	occupied_coords.erase(coord_)
	var windrose = coord_to_windrose[coord_]
	
	set_cell(coord_, 0, Catalog.EMPTY_INSECT_COORD)
	var windrose_approach = Catalog.windrose_to_mirror[windrose]
	var direction = Catalog.windrose_to_direction[windrose_approach]
	coord_ += direction
	
	if is_diagonal(coord_):
		coord_ -= direction
		detained_coords.append(coord_)
	else:
		if ring_to_coord[1].has(coord_):
			coord_ -= direction
		
		occupied_coords.append(coord_)
		set_cell(coord_, 0, Catalog.windrose_to_palette[windrose])

func release_detained_coords() -> void:
	if detained_coords.is_empty(): return
	
	while !detained_coords.is_empty():
		var coord = detained_coords.pop_back()
		var direction: Vector2i
		
		if abs(coord.x) > abs(coord.y):
			direction = Vector2i(0, -sign(coord.y))
		else:
			direction = Vector2i(-sign(coord.x), 0)
		
		
		coord += direction
		if occupied_coords.has(coord):
			coord -= direction
		
		var windrose = coord_to_windrose[coord]
		occupied_coords.append(coord)
		set_cell(coord, 0, Catalog.windrose_to_palette[windrose])


func is_diagonal(coord_: Vector2i) -> bool:
	return abs(coord_.x) == abs(coord_.y)
