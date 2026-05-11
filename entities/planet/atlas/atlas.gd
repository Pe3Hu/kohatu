extends TileMapLayer
class_name Atlas

const BASE_SIZE := 256

# =========================
# 🎛 GLOBAL SETTINGS
# =========================

@export var map_width: int = 192
@export var map_height: int = 108

@export var tile_size: int = 64

@export var seed_value: int = 12345

@export var cluster_count_base: int = 55

@export var base_density: float = 0.15

@export var smooth_strength_min: float = 0.3
@export var smooth_strength_max: float = 0.8

# 🎯 cluster distribution
@export var low_vein_density: float = 0.5
@export var medium_vein_density: float = 0.85

# 🎯 cluster parameters
@export var low_radius_min: int = 30
@export var low_radius_max: int = 55
@export var low_strength: float = 0.35

@export var medium_radius_min: int = 18
@export var medium_radius_max: int = 40
@export var medium_strength: float = 0.55

@export var high_radius_min: int = 10
@export var high_radius_max: int = 20
@export var high_strength: float = 0.9

# 💎 hotspots
@export var hotspot_chance_base: float = 0.7
@export var hotspot_strength_min: float = 0.9
@export var hotspot_strength_max: float = 1.0
@export var hotspot_radius_min: int = 3
@export var hotspot_radius_max: int = 6

# noise
@export var base_noise_freq: float = 0.02
@export var detail_noise_freq: float = 0.08


# =========================
# 🧠 INTERNAL
# =========================

var rng := RandomNumberGenerator.new()

var map_scale := 1.0

var base_noise := FastNoiseLite.new()
var detail_noise := FastNoiseLite.new()

var density_map = []


# =========================
# 🚀 ENTRY
# =========================

func _ready():
	generate(seed_value)


func generate(seed_: int):
	rng.seed = seed_
	
	map_scale = float(map_width) / float(BASE_SIZE)
	
	setup_noise(seed_)
	init_arrays()
	
	generate_base_layer()
	generate_clusters()
	finalize_map()
	render()


# =========================
# 🌍 NOISE
# =========================

func setup_noise(seed_):
	base_noise.seed = seed_ + 100
	base_noise.frequency = base_noise_freq * map_scale
	
	detail_noise.seed = seed_ + 200
	detail_noise.frequency = detail_noise_freq * map_scale


# =========================
# 📦 INIT
# =========================

func init_arrays():
	density_map.resize(map_width)
	
	for x in map_width:
		density_map[x] = []
		for y in map_height:
			density_map[x].append(0.0)


# =========================
# 🌱 BASE LAYER
# =========================

func generate_base_layer():
	for x in map_width:
		for y in map_height:
			
			var n = base_noise.get_noise_2d(x, y) * 0.5 + 0.5
			
			var base = base_density * (1.0 / map_scale)
			
			density_map[x][y] = n * base


# =========================
# 🏔 CLUSTERS
# =========================

func generate_clusters():
	
	var cluster_count = int(cluster_count_base * map_scale)
	var clusters = generate_seeds(cluster_count)
	
	for c in clusters:
		
		var roll = rng.randf()
		
		if roll < low_vein_density:
			apply_cluster(
				c,
				int(rng.randi_range(low_radius_min, low_radius_max) * map_scale),
				low_strength
			)
		
		elif roll < medium_vein_density:
			apply_cluster(
				c,
				int(rng.randi_range(medium_radius_min, medium_radius_max) * map_scale),
				medium_strength
			)
		
		else:
			apply_cluster(
				c,
				int(rng.randi_range(high_radius_min, high_radius_max) * map_scale),
				high_strength
			)


# =========================
# 💎 CLUSTER APPLY
# =========================

func apply_cluster(center_: Vector2i, radius_: int, strength_: float):
	
	for x in range(center_.x - radius_, center_.x + radius_):
		for y in range(center_.y - radius_, center_.y + radius_):
			
			var pos = Vector2i(x, y)
			if not in_bounds(pos):
				continue
			
			var dist = center_.distance_to(pos)
			if dist > radius_:
				continue
			
			var falloff = 1.0 - (dist / radius_)
			var n = detail_noise.get_noise_2d(x, y) * 0.5 + 0.5
			
			density_map[x][y] += strength_ * falloff * n
	
	# 💎 HOTSPOTS
	var hotspot_chance = hotspot_chance_base * map_scale
	
	var hotspot_count = 0
	if rng.randf() < hotspot_chance:
		hotspot_count = 1
	if rng.randf() < hotspot_chance * 0.3:
		hotspot_count += 1
	
	for i in hotspot_count:
		var half_radius = int(radius_ * 0.5)
		var offset = Vector2i(
			rng.randi_range(-half_radius, half_radius),
			rng.randi_range(-half_radius, half_radius)
		)
		
		var p = center_ + offset
		
		if in_bounds(p):
			apply_hotspot(p)


# =========================
# 💎 HOTSPOT
# =========================

func apply_hotspot(center_: Vector2i):
	
	var radius = int(rng.randi_range(
		hotspot_radius_min,
		hotspot_radius_max
	) * map_scale)
	
	var strength = rng.randf_range(
		hotspot_strength_min,
		hotspot_strength_max
	)
	
	for x in range(center_.x - radius, center_.x + radius):
		for y in range(center_.y - radius, center_.y + radius):
			
			var pos = Vector2i(x, y)
			if not in_bounds(pos):
				continue
			
			var dist = center_.distance_to(pos)
			if dist > radius:
				continue
			
			var falloff = 1.0 - (dist / radius)
			var n = 0.8 + detail_noise.get_noise_2d(x, y) * 0.2
			
			density_map[x][y] += strength * falloff * n


# =========================
# 🧼 FINALIZE
# =========================

func finalize_map():
	
	var smooth_strength = lerp(
		smooth_strength_max,
		smooth_strength_min,
		map_scale
	)
	
	var copy = density_map.duplicate(true)
	
	for x in range(1, map_width - 1):
		for y in range(1, map_height - 1):
			
			var sum = 0.0
			var count = 0
			
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					sum += copy[x + dx][y + dy]
					count += 1
			
			var avg = sum / count
			
			density_map[x][y] = lerp(
				density_map[x][y],
				avg,
				smooth_strength
			)


# =========================
# 🎨 RENDER
# =========================

func render():
	clear()
	
	for x in map_width:
		for y in map_height:
			
			var d = density_map[x][y]
			var tile = int(clamp(d * 9.0, 0, 9))
			
			set_cell(Vector2i(x, y), 0, Vector2i(tile, 0))


# =========================
# 🧰 UTILS
# =========================

func generate_seeds(count_: int):
	var seeds = []
	
	for _i in count_:
		seeds.append(Vector2i(
			rng.randi_range(0, map_width - 1),
			rng.randi_range(0, map_height - 1)
		))
	
	return seeds


func in_bounds(coord_: Vector2i):
	return coord_.x >= 0 and coord_.y >= 0 and coord_.x < map_width and coord_.y < map_height
