extends TileMapLayer
class_name Horde

@export var insect_scene: PackedScene
@export var site_scene: PackedScene
@export var sector_scene: PackedScene
@export var diagonal_scene: PackedScene

var sectors: Array[Sector] = []
var diagonals: Array[Diagonal] = []
var sites: Array[Site] = []
var insects: Array[Insect] = []

var coord_to_site: Dictionary = {}
var site_to_insect: Dictionary = {}

var windrose_to_sector: Dictionary = {}
var windrose_to_diagonal: Dictionary = {}

var claims: Dictionary = {}
var shift_direction

var active_cols: Array[Col]


#region init
func _ready() -> void:
	init_diagonals()
	init_sectors()
	init_sites()
	spawn_starter_insects()
	
	#for sector in sectors: 
		#var prev_line = sector.cols[0]
		#for site in prev_line.sites[0].sites:
			#set_cell(site.coord, 0, Catalog.windrose_to_palette[sector.windrose])
		
		#for col in sector.cols:
		#	var site = col.sites.front()
		#	set_cell(site.coord, 0, Catalog.windrose_to_palette[sector.windrose])
		
		#var prev_line = sector.cols.front()
		#var line = prev_line.promotion_to_row[false]
		#var site = prev_line.sites.front()
		#set_cell(site.coord, 0, Catalog.windrose_to_palette[sector.windrose])
		#for site in prev_line.sites: 
		#	set_cell(site.coord, 0, Catalog.windrose_to_palette[sector.windrose])

func init_diagonals() -> void:
	for windrose in Catalog.diagonal_windroses:
		var diagonal = diagonal_scene.instantiate()
		diagonal.setup(self, windrose)
		%Diagonals.add_child(diagonal)
		diagonals.append(diagonal)
		windrose_to_diagonal[windrose] = diagonal

func init_sectors() -> void:
	for windrose in Catalog.orthogonal_windroses:
		var sector = sector_scene.instantiate()
		sector.setup(self, windrose)
		%Sectors.add_child(sector)
		sectors.append(sector)
		windrose_to_sector[windrose] = sector

	for diagonal in diagonals:
		diagonal.init_neighbours()

	for sector in sectors:
		sector.init_line_neighbours()

func init_sites() -> void:
	for y in range(-Catalog.HORDE_MAX_RING, Catalog.HORDE_MAX_RING + 1):
		for x in range(-Catalog.HORDE_MAX_RING, Catalog.HORDE_MAX_RING + 1):
			var coord = Vector2i(x, y)
			var site = site_scene.instantiate()
			site.setup(self, coord)
			%Sites.add_child(site)
			sites.append(site)
			coord_to_site[coord] = site

	for sector in sectors:
		for col in sector.cols:
			col.sites.sort_custom(func(a, b): return a.ring > b.ring)
	
	for site in sites:
		site.init_sites()
#endregion

#region spawn
func spawn_starter_insects() -> void:
	for i in range(Catalog.STARTER_HORDE_INSECT_COUNT):
		add_insect()

func add_insect() -> void:
	var sector = choose_sector_for_spawn()
	if sector == null: return
	
	var col = choose_col_for_sector(sector)
	if col == null: return
	
	var site = pick_spawn_site(col)
	if site == null: return

	var insect = insect_scene.instantiate()
	%Insects.add_child(insect)
	insect.setup(self)

	register_insect(insect, site)
	if !active_cols.has(col):
		active_cols.append(col)

func register_insect(insect: Insect, site: Site):
	site_to_insect[site] = insect
	insect.site = site
	site.sector.population += 1
	site.col.insects.append(insect)

func pick_spawn_site(col: Col) -> Site:
	for site in col.sites:
		if is_free(site):
			return site
	return null

func choose_sector_for_spawn() -> Sector:
	var best_sector = null
	var best_score = INF

	for sector in sectors:
		if !sector.has_free_columns(): continue

		var score = sector.population
		if score == 0:
			score -= 100

		if score < best_score:
			best_score = score
			best_sector = sector

	return best_sector

func choose_col_for_sector(sector: Sector) -> Col:
	var cols = get_active_cols(sector)
	return cols.pick_random() if !cols.is_empty() else null
#endregion

#region naviagtion
func get_neighbour(site: Site, dir: Bozo.Windrose) -> Site:
	var coord = site.coord + Catalog.windrose_to_direction[dir]
	return coord_to_site.get(coord)

func map_through_diagonal(site: Site, diagonal_site: Site) -> Site:
	var target_sector = site.sector.diagonal_to_sector.get(diagonal_site.diagonal)
	return target_sector.cols.front().sites.front() if target_sector != null else site

func apply_shift(site: Site, shift_dir: Bozo.Windrose) -> Site:
	return null

#endregion

func shift(dir):
	shift_direction = dir
	tick()

func tick():
	build_intents()
	resolve_conflicts()
	commit_phase()

func build_intents():
	for insect in insects:
		insect.intent_path.clear()

		var shifted_site = apply_shift(insect.site, shift_direction)
		insect.intent_path.append(shifted_site)

		#for next_site in [
			#get_forward(shifted_site),
			#get_align(shifted_site),
			#get_side(shifted_site),
			#get_back(shifted_site)
		#]:
			#if is_free(next_site):
				#insect.intent_path.append(next_site)
				#break

func resolve_conflicts():
	claims.clear()

	for insect in insects:
		var target_site = insect.intent_path.back()
		if !claims.has(target_site):
			claims[target_site] = []
		claims[target_site].append(insect)

	for site in claims:
		var conflict_list = claims[site]
		if conflict_list.size() <= 1: continue

		for i in range(1, conflict_list.size()):
			var insect = conflict_list[i]
			var fallback_site = insect.site.back
			insect.intent_path = [fallback_site] if is_free(fallback_site) else [insect.site]

func commit_phase():
	site_to_insect.clear()

	for insect in insects:
		insect.follow_intent()
		#insect.global_position = final_site.global_position

func shit_forward() -> void:
	for col in active_cols:
		col.parallel_shift(false)
	
	commit_phase()

#func _input(event: InputEvent) -> void:
	#if event is InputEventKey and event.pressed:
		#if Input.is_key_pressed(KEY_SPACE):
			#shit_forward()
		#if Input.is_key_pressed(KEY_W):
			#shift(Bozo.Windrose.S)
		#elif Input.is_key_pressed(KEY_S):
			#shift(Bozo.Windrose.N)
		#elif Input.is_key_pressed(KEY_A):
			#shift(Bozo.Windrose.E)
		#elif Input.is_key_pressed(KEY_D):
			#shift(Bozo.Windrose.W)


#region help
func is_free(site: Site) -> bool:
	return site != null and !site_to_insect.has(site)

func is_col_used(col: Col) -> bool:
	for site in col.sites:
		if site_to_insect.has(site):
			return true
	return false

func get_active_cols(sector: Sector) -> Array[Col]:
	var result: Array[Col] = []
	var visited: Dictionary = {}
	var queue: Array[Col] = []

	var center_col = sector.index_to_col.get(0)
	if center_col == null:
		return result

	queue.append(center_col)
	visited[center_col] = true

	while !queue.is_empty():
		var col = queue.pop_front()

		if !is_col_used(col):
			result.append(col)
			continue

		for dir in [true, false]:
			var neighbour_col = col.clockwise_to_col.get(dir)
			if neighbour_col != null and !visited.has(neighbour_col):
				visited[neighbour_col] = true
				queue.append(neighbour_col)

	return result
#endregion
