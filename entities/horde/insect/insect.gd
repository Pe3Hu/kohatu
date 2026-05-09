extends Area2D
class_name Insect


var horde: Horde
var coord: Vector2i
var index: int:
	set(value_):
		index = value_
		%IndexLabel.text = str(index)

var intent: Vector2i = Vector2i.ZERO


func setup(horde_: Horde, coord_: Vector2i) -> void:
	horde = horde_
	coord = coord_
	
	index = horde.insects.size()
	horde.insects.append(self)
	horde.coord_to_insect[coord] = self
	var windrose = horde.coord_to_windrose[coord]
	horde.set_cell(coord, 0, Catalog.windrose_to_palette[windrose])
	position = horde.map_to_local(coord)

func request_move(direction_: Vector2i) -> void:
	intent = direction_
