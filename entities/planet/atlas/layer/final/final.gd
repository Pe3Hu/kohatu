extends BaseLayer
class_name FinalOreLayer

func generate(_atlas: Atlas):
	super(_atlas)
	_build_final_map()
	_add_edge_clusters()
	_post_process_map()
	render()

func _build_final_map():
	var center_layer = atlas.center_layer
	var ridge_layer = atlas.ridge_layer
	var sector_layer = atlas.sector_layer
	var ore_layer = atlas.ore_layer

	var raw_values := PackedFloat32Array()
	raw_values.resize(data.size())

	for y in range(atlas.map_height):
		for x in range(atlas.map_width):
			var i = index(x, y)

			var center_v = center_layer.data[i]
			var ridge_v = ridge_layer.data[i]
			var sector_v = sector_layer.data[i]
			var ore_v = ore_layer.data[i]

			if center_v != 0.0:
				raw_values[i] = remap(1 - center_v, 0, 1, 0.3, 1.2)
				continue

			if ridge_v != 0.0:
				raw_values[i] = (1.0 - ridge_v) * 0.5
				continue

			raw_values[i] = (sector_v + ore_v) * 0.6

	var min_v := INF
	var max_v := -INF

	for i in range(raw_values.size()):
		var v = raw_values[i]
		if v == 0.0:
			continue
		if v == 0.2:
			continue
		min_v = min(min_v, v)
		max_v = max(max_v, v)

	var range_v = max(max_v - min_v, 0.0001)

	for i in range(raw_values.size()):
		#var center_v = center_layer.data[i]
		var v = raw_values[i]

		#if center_v > 0.1:
		#	data[i] = 0.4
		#	continue

		var normalized = (v - min_v) / range_v
		data[i] = snapped(remap(normalized, min_v, 1.0, 0.1, 1.0), 0.1)

func _add_edge_clusters():
	var sector_layer = atlas.sector_layer

	for sector in sector_layer.sectors:
		var coords = sector.coords
		if coords.is_empty():
			continue

		var edge_cells: Array[Vector2i] = []

		for c in coords:
			if _is_on_map_edge(c) and _is_inside(c):
				edge_cells.append(c)

		if edge_cells.size() < 6:
			continue

		edge_cells.sort_custom(func(a, b):
			return Vector2(a).angle() < Vector2(b).angle()
		)

		var p1 = edge_cells[int(edge_cells.size() * 0.1)]
		var p2 = edge_cells[int(edge_cells.size() * 0.5)]
		var p3 = edge_cells[int(edge_cells.size() * 0.9)]

		_place_cluster(p1)
		_place_cluster(p2)
		_place_cluster(p3)

func _place_cluster(center: Vector2i):
	var placed := 0
	var cluster_cells := []

	var offsets = [
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]

	for o in offsets:
		if placed >= 3:
			break

		var c = center + o

		if not _is_inside(c):
			continue

		var i = index(c.x, c.y)
		
		data[i] = remap(data[i] + 1, 0, 2.0, 0.0, 1.0)

		cluster_cells.append(c)
		placed += 1

	for cell in cluster_cells:
		for n in [
			Vector2i(1, 0),
			Vector2i(-1, 0),
			Vector2i(0, 1),
			Vector2i(0, -1)
		]:
			var nc = cell + n
			if not _is_inside(nc):
				continue

			var ni = index(nc.x, nc.y)
			
			data[ni] = remap(data[ni] + 0.5, 0.5, 1.0, 0.0, 1.0)

func _is_on_map_edge(p: Vector2i) -> bool:
	return p.x == 0 or p.y == 0 or p.x == atlas.map_width - 1 or p.y == atlas.map_height - 1

func _is_inside(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < atlas.map_width and p.y < atlas.map_height

func _post_process_map():
	for i in range(data.size()):
		var v = data[i]

		if v <= 0.4:
			continue

		var roll := atlas.rng.randf()

		# 1% шанс — сразу в 1
		if roll < 0.01:
			data[i] = 1.0
			continue

		# 4% шанс — поднять на половину расстояния до 1
		elif roll < 0.05:
			var delta = 1.0 - v
			data[i] = clamp(v + delta * 0.5, 0.0, 1.0)
			continue
