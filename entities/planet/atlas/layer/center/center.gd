extends BaseLayer
class_name CenterLayer

@export var blob_radius_factor: float = 0.2
@export var noise_strength: float = 0.35

var noise := FastNoiseLite.new()

func generate(_atlas: Atlas):
	super(_atlas)

	noise.seed = atlas.rng.randi()
	noise.frequency = 0.08

	var cx = atlas.map_width * 0.5
	var cy = atlas.map_height * 0.5

	var base_r = min(atlas.map_width, atlas.map_height) * blob_radius_factor

	for y in range(atlas.map_height):
		for x in range(atlas.map_width):

			var i = index(x, y)

			var dx = x - cx
			var dy = y - cy

			var dist = sqrt(dx*dx + dy*dy)

			# 🌿 шум деформирует радиус (ключ!)
			var n = noise.get_noise_2d(x, y) * 0.5 + 0.5
			var warped_r = base_r * (1.0 + (n - 0.5) * noise_strength)

			if dist < warped_r:
				data[i] = 0.2
			else:
				data[i] = 0.0

	render()
