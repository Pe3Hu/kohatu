extends TileMapLayer
class_name Horde


@export var insect_scene: PackedScene
@export var site_scene: PackedScene
@export var sector_scene: PackedScene
@export var diagonal_scene: PackedScene


var sectors: Array[Sector]
var diagonals: Array[Diagonal]
var sites: Array[Site]
var insects: Array[Insect]

var windrose_to_sector: Dictionary
var windrose_to_diagonal: Dictionary
var coord_to_site: Dictionary

var ring_to_coord: Dictionary
var coord_to_ring: Dictionary
var coord_to_windrose: Dictionary
var windrose_to_coord: Dictionary
var coord_to_insect: Dictionary

var spawn_coords: Array[Vector2i]

var intents: Dictionary


func _ready() -> void:
	init_sectors()
	init_diagonals()
	init_sites()
	
	for sector in sectors:
		var row = sector.rows.back()
		
		for site in row.sites:
			set_cell(site.coord, 0, Catalog.windrose_to_palette[sector.windrose])
	#init_spawn_coords()
	#init_insects()

func init_sectors() -> void:
	for windrose in Catalog.orthogonal_windroses:
		add_sector(windrose)

func add_sector(windrose_: Bozo.Windrose) -> void:
	var sector = sector_scene.instantiate()
	sector.setup(self, windrose_)
	%Sectors.add_child(sector)
	sectors.append(sector)
	windrose_to_sector[windrose_] = sector

func init_diagonals() -> void:
	for windrose in Catalog.diagonal_windroses:
		add_diagonal(windrose)

func add_diagonal(windrose_: Bozo.Windrose) -> void:
	var diagonal = diagonal_scene.instantiate()
	diagonal.setup(self, windrose_)
	%Diagonals.add_child(diagonal)
	diagonals.append(diagonal)
	windrose_to_diagonal[windrose_] = diagonal

func init_sites() -> void:
	for _y in range(-Catalog.HORDE_MAX_RING, Catalog.HORDE_MAX_RING + 1, 1):
		for _x in range(-Catalog.HORDE_MAX_RING, Catalog.HORDE_MAX_RING + 1, 1):
			var coord = Vector2i(_x, _y)
			add_site(coord)
			#var ring = max(abs(_y), abs(_x))
			#
			#if !ring_to_coord.has(ring):
				#ring_to_coord[ring] = []
			#
			#ring_to_coord[ring].append(coord)
			#coord_to_ring[coord] = ring
			#var windrose = null
			#
			
			#else:
			#
			#if windrose != null:
				#coord_to_windrose[coord] = windrose
				#windrose_to_coord[windrose].append(coord)


func add_site(coord_: Vector2i) -> void:
	var site = site_scene.instantiate()
	site.setup(self, coord_)
	%Sites.add_child(site)
	sites.append(site)
	coord_to_site[coord_] = site

func init_spawn_coords() -> void:
	for windrose in Catalog.orthogonal_windroses:
		var max_ring_coords = ring_to_coord[Catalog.HORDE_MAX_RING]
		max_ring_coords = max_ring_coords.filter(func (a): return windrose_to_coord[windrose].has(a))
		#for coord in windrose_to_coord[windrose]:
		#	var ring = coord_to_ring[coord]
		#	if ring > 1:
		#		set_cell(coord, 0, Catalog.windrose_to_palette[windrose])
		var coord = max_ring_coords[Catalog.HORDE_MAX_RING - 1]
		spawn_coords.append(coord)

func init_insects() -> void:
	for _i in Catalog.STARTER_HORDE_INSECT_COUNT:
		add_insect()

func add_insect() -> void:
	var insect = insect_scene.instantiate()
	var coord = spawn_coords.pick_random()
	%Insects.add_child(insect)
	insect.setup(self, coord)
	update_spawn_coord(insect)

func update_spawn_coord(insect_: Insect) -> void:
	spawn_coords.erase(insect_.coord)
	var windrose = coord_to_windrose[insect_.coord]
	
	for direction in Catalog.windrose_to_neighbour[windrose]:
		var neighbour_coord = insect_.coord + direction
		
		if !is_diagonal(neighbour_coord) and !coord_to_insect.has(neighbour_coord):
			spawn_coords.append(neighbour_coord)

func shift(windrose_: Bozo.Windrose) -> void:
	pass

func collect_intents() -> void:
	intents.clear()
	
	for insect in insects:
		var windrose = coord_to_windrose[insect.coord]
		var dir = Catalog.windrose_to_direction[
			Catalog.windrose_to_mirror[windrose]
		]
		
		intents[insect] = dir

func resolve_intents() -> Dictionary:
	var target_map = {}
	var final_moves = {}
	
	var sorted = intents.keys()
	sorted.sort_custom(func(a, b):
		return coord_to_ring[a.coord] > coord_to_ring[b.coord]
	)
	
	for insect in sorted:
		var dir = intents[insect]
		var target = insect.coord + dir
		
		# ❌ граница поля
		if !is_inside_border(target):
			continue
		
		# ❌ занято
		if coord_to_insect.has(target):
			continue
		
		# ❌ конфликт
		if target_map.has(target):
			continue
		
		# 🚫 RING = 1 → стоп без попыток
		if coord_to_ring.get(target, -1) == 1:
			continue
		
		# ⚠️ ДИАГОНАЛЬНОЕ ПРАВИЛО
		if is_diagonal(target):
			var fallback_dir = get_center_pull(insect.coord)
			var fallback_target = insect.coord + fallback_dir
			
			if is_valid_move(insect, fallback_target, target_map):
				target_map[fallback_target] = insect
				final_moves[insect] = fallback_dir
			
			continue
		
		# ✅ обычное движение
		target_map[target] = insect
		final_moves[insect] = dir
	
	return final_moves

func get_center_pull(coord: Vector2i) -> Vector2i:
	if abs(coord.x) > abs(coord.y):
		return Vector2i(0, -sign(coord.y))
	else:
		return Vector2i(-sign(coord.x), 0)

func is_valid_move(insect: Insect, target: Vector2i, target_map: Dictionary) -> bool:
	if !is_inside_border(target):
		return false
	
	if coord_to_insect.has(target):
		return false
	
	if target_map.has(target):
		return false
	
	return true

func apply_movements(moves: Dictionary) -> void:
	for insect in moves.keys():
		var dir = moves[insect]
		
		set_cell(insect.coord, 0, Catalog.EMPTY_INSECT_COORD)
		coord_to_insect.erase(insect.coord)
		
		insect.coord += dir
		
		coord_to_insect[insect.coord] = insect
		
		var windrose = coord_to_windrose[insect.coord]
		set_cell(insect.coord, 0, Catalog.windrose_to_palette[windrose])
		
		insect.position = map_to_local(insect.coord)

func simulate_step() -> void:
	collect_intents()
	var moves = resolve_intents()
	apply_movements(moves)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if Input.is_key_pressed(KEY_SPACE):
			simulate_step()
		if Input.is_key_pressed(KEY_W):
			shift(Bozo.Windrose.S)
		if Input.is_key_pressed(KEY_A):
			shift(Bozo.Windrose.W)
		if Input.is_key_pressed(KEY_S):
			shift(Bozo.Windrose.N)
		if Input.is_key_pressed(KEY_D):
			shift(Bozo.Windrose.E)

func is_diagonal(coord_: Vector2i) -> bool:
	return abs(coord_.x) == abs(coord_.y)

func is_inside_border(coord_: Vector2i) -> bool:
	if abs(coord_.x) > Catalog.HORDE_MAX_RING: return false
	if abs(coord_.y) > Catalog.HORDE_MAX_RING: return false
	return true

func is_direction_free(direction_: Vector2i) -> bool:
	var coord
	if is_diagonal(coord + direction_):
		return false
	
	if ring_to_coord[1].has(coord + direction_):
		return false
	
	if coord_to_insect.has(coord + direction_):
		return false
	
	return true
