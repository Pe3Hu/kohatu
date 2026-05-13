extends BaseLayer
class_name RidgeLayer

@export var segment_count: int = 10
@export var noise_amplitude: float = 15.0

@export var ridge_width_center: float = 4.0
@export var ridge_width_edge: float = 24.0

@export var river_core_width: float = 6.0
@export var river_falloff: float = 12.0     

@export var center_radius_factor: float = 0.2

var noise := FastNoiseLite.new()

var ridges = []
var rivers = []


func generate(_atlas: Atlas):
	super(_atlas)

	noise.seed = atlas.rng.randi()
	noise.frequency = 0.05

	var center = Vector2(atlas.map_width * 0.5, atlas.map_height * 0.5)
	var base_radius = min(atlas.map_width, atlas.map_height) * center_radius_factor

	var corners = [
		Vector2(0, 0),
		Vector2(atlas.map_width - 1, 0),
		Vector2(atlas.map_width - 1, atlas.map_height - 1),
		Vector2(0, atlas.map_height - 1)
	]

	# очистка (всё чёрное)
	for i in range(data.size()):
		data[i] = 0.0

	ridges.clear()
	rivers.clear()

	# =========================
	# ⛰ ХРЕБТЫ
	# =========================
	for c in corners:
		var dir = (c - center).normalized()
		var start = center + dir * base_radius
		var end = c
		ridges.append(_build_ridge(start, end, dir))

	# =========================
	# 🌊 РЕКИ (ромб)
	# =========================
	#enum Windrose{
		#N,
		#NE,
		#E,
		#SE,
		#S,
		#SW,
		#W,
		#NW
	#}
	
	#var corner_nw = Vector2(0, 0)
	#var corner_ne = Vector2(atlas.map_width - 1, 0)
	#var corner_se = Vector2(atlas.map_width - 1, atlas.map_height - 1)
	#var orner_sw = Vector2(0, atlas.map_height - 1)
	
	var edge_n = Vector2(atlas.map_width / 2, 0)
	var edge_e = Vector2(atlas.map_width - 1, atlas.map_height / 2)
	var edge_s = Vector2(atlas.map_width / 2, atlas.map_height - 1)
	var edge_w = Vector2(0, atlas.map_height / 2)

	#var corners = [corner_nw, corner_ne, corner_se, orner_sw]
	var edges = [edge_n, edge_e, edge_s, edge_w]

	for _i in corners.size():
		var begin = _river_point(corners[_i], edges[_i])
		var _j = (_i - 1 + edges.size()) % edges.size()
		var end = _river_point(corners[_i], edges[_j])
		rivers.append(_build_river(begin, end))

	# =========================
	# 🌍 РЕНДЕР
	# =========================
	for y in range(atlas.map_height):
		for x in range(atlas.map_width):

			var p = Vector2(x, y)

			# -------------------------
			# ⛰ ХРЕБТЫ (база)
			# -------------------------
			var ridge_value := 0.0

			for r in ridges:
				var points = r["points"]

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

					var local_t = float(i) / float(points.size())
					var width = lerp(ridge_width_center, ridge_width_edge, local_t)

					var m = smoothstep(width, 0.0, d)
					ridge_value = max(ridge_value, m)

			# если нет хребта — остаётся чёрным
			if ridge_value <= 0.0:
				continue

			var value = ridge_value

			# -------------------------
			# 🌊 РЕКИ (ВЫРЕЗАЮТ ХРЕБТЫ)
			# -------------------------
			for river in rivers:
				var points = river["points"]

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

					# 🔥 ядро реки (чистый проход)
					var core = smoothstep(river_core_width, 0.0, d)

					# мягкое расширение
					var falloff = smoothstep(river_falloff, river_core_width, d)

					# итог: центр = 1, края = 0
					var river_mask = core * falloff

					# 🔥 ВЫРЕЗАЕМ хребет
					value = min(value, 1.0 - river_mask)

			data[index(x, y)] = value

	render()


# =========================
# ⛰ ХРЕБЕТ
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


# =========================
# 🌊 РЕКА
# =========================
func _build_river(start: Vector2, end: Vector2):

	var dir = (end - start).normalized()
	var perp = Vector2(-dir.y, dir.x)

	var points = []

	for i in range(segment_count + 1):
		var t = float(i) / float(segment_count)

		var base = start.lerp(end, t)
		var n = noise.get_noise_2d(base.x, base.y)

		var offset = perp * n * (noise_amplitude * 0.4)

		points.append(base + offset)

	return {
		"points": points,
		"dir": dir
	}


func _river_point(a: Vector2, b: Vector2) -> Vector2:
	# выбираем направление от одного из концов
	var r = atlas.rng.randf_range(0.3, 0.6)
	var c = (b - a).normalized()
	var l = (b - a).length() * r
	return a + c * l
