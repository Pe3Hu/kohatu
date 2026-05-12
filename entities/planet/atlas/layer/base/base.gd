extends TileMapLayer
class_name BaseLayer

var atlas: Atlas
var data: PackedFloat32Array

func generate(_atlas: Atlas):

	atlas = _atlas  # 🔥 ВАЖНО — сохраняем контекст

	data = PackedFloat32Array()
	data.resize(atlas.map_width * atlas.map_height)

func index(x:int, y:int) -> int:
	return x + y * atlas.map_width

func render():
	clear()

	for y in range(atlas.map_height):
		for x in range(atlas.map_width):

			var i = x + y * atlas.map_width
			var v = data[i]

			var tile = int(clamp(v * 9.0, 0, 9))

			set_cell(Vector2i(x, y), 0, Vector2i(tile, 0))
