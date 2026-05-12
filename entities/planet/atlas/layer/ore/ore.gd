extends BaseLayer
class_name OreLayer

# =========================
# 🧠 CONFIG
# =========================

@export var large_vein_value := 0.7
@export var medium_vein_value := 0.35
@export var small_vein_value := 0.15

@export var large_vein_size_ratio := 0.18

@export var medium_vein_count_min := 3
@export var medium_vein_count_max := 5

@export var small_vein_threshold := 0.78

@export var noise_scale := 0.08

# =========================
# 🌊 NOISE
# =========================

var noise := FastNoiseLite.new()


# =========================
# 🚀 ENTRY POINT
# =========================

func generate(_atlas: Atlas):
	super(_atlas)

	noise.seed = atlas.rng.randi()
	noise.frequency = noise_scale

	_generate_ore()
	_normalize()
	render()


# =========================
# 🪨 MAIN GENERATION
# =========================

func _generate_ore():

	# clear layer
	for i in range(data.size()):
		data[i] = 0.0

	var sector_layer: SectorLayer = atlas.sector_layer

	for sector in sector_layer.sectors:

		var coords = sector.coords
		if coords.is_empty():
			continue

		_place_large_vein(coords)
		_place_medium_veins(coords)
		_place_small_veins(coords)


# =========================
# 🔴 LARGE VEIN (CORE STRUCTURE)
# =========================

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

		# add + noise variation
		var n = noise.get_noise_2d(c.x, c.y) * 0.1

		data[i] += large_vein_value * falloff + n


# =========================
# 🟠 MEDIUM VEINS (CLUSTERS)
# =========================

func _place_medium_veins(coords: Array):

	var count = randi_range(medium_vein_count_min, medium_vein_count_max)

	for i in range(count):

		var seed = coords[randi() % coords.size()]
		_splat_vein(seed, coords, medium_vein_value, 10)


# =========================
# 🟡 SMALL VEINS (SCATTER NOISE)
# =========================

func _place_small_veins(coords: Array):

	for c in coords:

		if not _is_valid_cell(c):
			continue

		var n = noise.get_noise_2d(c.x, c.y)
		var chance = (n + 1.0) * 0.5

		if chance > small_vein_threshold:

			var i = index(c.x, c.y)
			data[i] += small_vein_value


# =========================
# 💥 SPLAT SYSTEM (CORE CLUSTER LOGIC)
# =========================

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


# =========================
# 🚫 VALIDATION (CENTER + RIDGE BLOCKS)
# =========================

func _is_valid_cell(p: Vector2i) -> bool:

	var i = index(p.x, p.y)

	# center block
	if atlas.center_layer.data[i] > 0.1:
		return false

	# ridge block
	if atlas.ridge_layer.data[i] > 0.5:
		return false

	return true


# =========================
# 📊 NORMALIZATION (CRITICAL)
# =========================

func _normalize():

	var min_v := INF
	var max_v := -INF

	for i in range(data.size()):
		min_v = min(min_v, data[i])
		max_v = max(max_v, data[i])

	var range_v = max(max_v - min_v, 0.0001)

	for i in range(data.size()):
		data[i] = (data[i] - min_v) / range_v
