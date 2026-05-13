extends BaseLayer
class_name CenterLayer

@export var blob_radius_factor: float = 0.35
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

			var dist = sqrt(dx * dx + dy * dy)

			# шум деформирует радиус (сохраняем кляксу)
			var n = noise.get_noise_2d(x, y) * 0.5 + 0.5
			var warped_r = base_r * (1.0 + (n - 0.5) * noise_strength)

			if warped_r > 0.0 and dist < warped_r:
				var t = dist / warped_r  # 0 в центре → 1 на границе

				# плавное затухание
				var falloff = 1.0 - t

				# можно сделать более "мягкий центр"
				falloff = falloff * falloff
				
				if falloff > 0.2:
					data[i] = remap(falloff, 0, 1, 0.0, 0.9)
				else:
					data[i] = 0.0
			else:
				data[i] = 0.0

	render()
