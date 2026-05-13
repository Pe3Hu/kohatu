extends BaseLayer
class_name OreLayer

@export var large_vein_value := 0.8
@export var medium_vein_value := 0.5
@export var large_vein_size_ratio := 0.18
@export var medium_vein_count_min := 8
@export var medium_vein_count_max := 12
@export var noise_scale := 0.25

var noise := FastNoiseLite.new()

func generate(_atlas: Atlas):
	super(_atlas)
	noise.seed = atlas.rng.randi()
	noise.frequency = noise_scale
	_generate_ore()
	_normalize()
	render()

func _generate_ore():
	for i in range(data.size()):
		data[i] = 0.0

	var sector_layer: SectorLayer = atlas.sector_layer

	for sector in sector_layer.sectors:
		var coords = sector.coords
		if coords.is_empty():
			continue
		_place_large_vein(coords)
		_place_medium_veins(coords)

func _place_large_vein(coords: Array):
	var center = coords[randi() % coords.size()]
	var radius = int(coords.size() * large_vein_size_ratio)

	for c in coords:
		var d = c.distance_to(center)
		if d > radius:
			continue
		if not _is_valid_cell(c):
			continue

		var falloff = 1.0 - (d / float(radius))
		falloff *= falloff

		var i = index(c.x, c.y)
		var n = noise.get_noise_2d(c.x, c.y) * 0.1
		data[i] += large_vein_value * falloff + n

func _place_medium_veins(coords: Array):
	var count = randi_range(medium_vein_count_min, medium_vein_count_max)
	for i in range(count):
		var seed = coords[randi() % coords.size()]
		_splat_vein(seed, coords, medium_vein_value, 16)

func _splat_vein(seed: Vector2i, coords: Array, value: float, radius: int):
	for c in coords:
		if not _is_valid_cell(c):
			continue

		var d = c.distance_to(seed)
		if d > radius:
			continue

		var falloff = 1.0 - (d / float(radius))
		falloff *= falloff

		var i = index(c.x, c.y)
		data[i] += value * falloff

func _is_valid_cell(p: Vector2i) -> bool:
	var i = index(p.x, p.y)
	if atlas.center_layer.data[i] > 0.1:
		return false
	if atlas.ridge_layer.data[i] > 0.1:
		return false
	return true

func _is_on_map_edge(p: Vector2i) -> bool:
	return p.x == 0 or p.y == 0 or p.x == atlas.map_width - 1 or p.y == atlas.map_height - 1

func _is_inside(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < atlas.map_width and p.y < atlas.map_height

func _normalize():
	var min_v := INF
	var max_v := -INF

	for i in range(data.size()):
		min_v = min(min_v, data[i])
		max_v = max(max_v, data[i])

	var range_v = max(max_v - min_v, 0.0001)

	for i in range(data.size()):
		var normalized = (data[i] - min_v) / range_v
		if normalized > 0.1:
			data[i] = clamp(normalized, 0.2, 1.0)
		else:
			data[i] = normalized
