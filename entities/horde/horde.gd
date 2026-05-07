extends TileMapLayer
class_name Horde


var ring_to_coords: Dictionary

func _ready() -> void:
	init_insects()

func init_insects() -> void:
	for _y in range(-Catalog.HORDE_INSECT_SIZE.y, Catalog.HORDE_INSECT_SIZE.y + 1, 1):
		for _x in range(-Catalog.HORDE_INSECT_SIZE.x, Catalog.HORDE_INSECT_SIZE.x + 1, 1):
			var coord = Vector2i(_x, _y)
			var ring = max(abs(_y), abs(_x))
			
			if !ring_to_coords.has(ring):
				ring_to_coords[ring] = []
			
			ring_to_coords[ring].append(coord)
			var coordinate = Vector2i(0, (ring % 4))
			
			set_cell(coord, 0, coordinate)

func add_axis() -> void:
	pass
