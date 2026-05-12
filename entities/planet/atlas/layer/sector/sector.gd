extends BaseLayer
class_name SectorLayer


@export var ridge_block_threshold: float = 0.5
@export var center_block_threshold: float = 0.1

var coord_to_windrose: Dictionary
var windrose_to_sector: Dictionary

var sectors: Array[SectorData]

var frontier := []
var visited := {}


func generate(_atlas: Atlas):
	super(_atlas)

	coord_to_windrose.clear()
	frontier.clear()
	visited.clear()

	init_sectors()
	init_seeds()
	run_flood_fill()

	update_data()


func init_sectors():
	windrose_to_sector.clear()
	
	var economy_options = [
		Bozo.Economy.RICH,
		Bozo.Economy.NORMAL,
		Bozo.Economy.NORMAL,
		Bozo.Economy.POOR,
	]
	economy_options.shuffle()
	
	for windrose in Catalog.orthogonal_windroses:
		var economy = economy_options.pop_back()
		add_sector(windrose, economy)

func add_sector(windrose_: Bozo.Windrose, economy_: Bozo.Economy) -> void:
	var sector = SectorData.new(windrose_, economy_)
	windrose_to_sector[windrose_] = sector
	sectors.append(sector)

func init_seeds():
	var w = int(atlas.map_width * 0.5)
	var h = int(atlas.map_height * 0.5)

	enqueue(Vector2i(w, 0), Bozo.Windrose.N)
	enqueue(Vector2i(w * 2 - 1, h), Bozo.Windrose.E)
	enqueue(Vector2i(w, h * 2 - 1), Bozo.Windrose.S)
	enqueue(Vector2i(0, h), Bozo.Windrose.W)

func run_flood_fill():
	while frontier.size() > 0:

		var node = frontier.pop_front()
		var coord: Vector2i = node.coord
		var windrose: Bozo.Windrose = node.windrose

		if visited.has(coord):
			continue

		visited[coord] = true
		coord_to_windrose[coord] = windrose
		var sector = windrose_to_sector[windrose]
		sector.coords.append(coord)

		for n in _neighbors(coord):

			if visited.has(n):
				continue

			if _is_blocked(n):
				continue

			frontier.append({
				"coord": n,
				"windrose": windrose
			})

# =========================
# BLOCKING LOGIC (CENTER + RIDGE)
# =========================

func _is_blocked(p: Vector2i) -> bool:
	if p.x < 0 or p.y < 0: return true
	if p.x >= atlas.map_width or p.y >= atlas.map_height: return true

	var i = index(p.x, p.y)

	# Center layer block
	if "center_layer" in atlas:
		var c = atlas.center_layer.data[i]
		if c > center_block_threshold: return true

	# Ridge layer block
	if "ridge_layer" in atlas:
		var r = atlas.ridge_layer.data[i]
		if r > ridge_block_threshold: return true

	return false

# =========================
# QUEUE HELPERS
# =========================

func enqueue(coord: Vector2i, windrose: Bozo.Windrose):

	if _is_blocked(coord):
		return

	frontier.append({
		"coord": coord,
		"windrose": windrose
	})

# =========================
# NEIGHBORS
# =========================

func _neighbors(p: Vector2i) -> Array:

	return [
		p + Vector2i(1, 0),
		p + Vector2i(-1, 0),
		p + Vector2i(0, 1),
		p + Vector2i(0, -1)
	]

# =========================
# RENDER DEBUG VIEW
# =========================

func update_data():
	for sector in sectors:
		for coord in sector.coords:
			var i = index(coord.x, coord.y)
			data[i] = Catalog.economy_to_weight[sector.economy]
	
	render()
