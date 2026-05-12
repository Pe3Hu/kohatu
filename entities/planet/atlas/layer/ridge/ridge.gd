extends BaseLayer
class_name RidgeLayer

@export var segment_count: int = 10
@export var noise_amplitude: float = 15.0

@export var ridge_width_center: float = 4.0
@export var ridge_width_edge: float = 10.0

@export var center_radius_factor: float = 0.15

var noise := FastNoiseLite.new()

var ridges = []


func generate(_atlas: Atlas):
	super(_atlas)

	noise.seed = atlas.rng.randi()
	noise.frequency = 0.05

	var center = Vector2(atlas.map_width * 0.5, atlas.map_height * 0.5)
	var base_radius = min(atlas.map_width, atlas.map_height) * center_radius_factor

	var corners = [
		Vector2(0, 0),
		Vector2(atlas.map_width - 1, 0),
		Vector2(0, atlas.map_height - 1),
		Vector2(atlas.map_width - 1, atlas.map_height - 1)
	]

	# очистка
	for i in range(data.size()):
		data[i] = 0.0

	ridges.clear()

	# =========================
	# 🔥 СОЗДАЁМ РЕБРА
	# =========================

	for c in corners:

		var dir = (c - center).normalized()

		var start = center + dir * base_radius
		var end = c

		ridges.append(_build_ridge(start, end, dir))

	# =========================
	# 🌊 РЕНДЕР С ОГРАНИЧЕНИЕМ ВЛИЯНИЯ
	# =========================

	for y in range(atlas.map_height):
		for x in range(atlas.map_width):

			var p = Vector2(x, y)

			var best_ridge = -1
			var best_dist = INF
			var best_t = 0.0

			for r in range(ridges.size()):

				var ridge = ridges[r]

				# 🔥 проверка принадлежности (угловая доминация)
				var dir_to_center = (p - Vector2(atlas.map_width*0.5, atlas.map_height*0.5)).normalized()
				var ridge_dir = ridge["dir"]

				# если не в своём секторе — пропускаем
				if dir_to_center.dot(ridge_dir) < 0.2:
					continue

				var points = ridge["points"]

				for i in range(points.size() - 1):

					var a = points[i]
					var b = points[i + 1]

					var seg = b - a
					var len2 = seg.length_squared()

					if len2 == 0:
						continue

					var t = (p - a).dot(seg) / len2
					t = clamp(t, 0.0, 1.0)

					var closest = a + seg * t

					var d = p.distance_to(closest)

					if d < best_dist:
						best_dist = d
						best_ridge = r
						best_t = float(i) / float(points.size())

			if best_ridge == -1:
				continue

			var width = lerp(ridge_width_center, ridge_width_edge, best_t)

			var m = best_dist / width
			var mask = smoothstep(1.0, 0.0, m)

			var idx = index(x, y)

			data[idx] = max(data[idx], mask)
	
	render()


# =========================
# 🌊 BUILD ONE RIDGE
# =========================

func _build_ridge(start: Vector2, end: Vector2, dir: Vector2):

	var perp = Vector2(-dir.y, dir.x)

	var points = []

	for i in range(segment_count + 1):

		var t = float(i) / float(segment_count)

		var base = start.lerp(end, t)

		var n = noise.get_noise_2d(base.x, base.y)

		var offset = perp * n * noise_amplitude

		points.append(base + offset)

	return {
		"points": points,
		"dir": dir
	}
