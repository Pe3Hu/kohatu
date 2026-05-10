extends Node2D
class_name Diagonal


var horde: Horde
var sectors: Array[Sector]
var windrose: Bozo.Windrose
var sites: Array[Site]


func setup(horde_: Horde, windrose_: Bozo.Windrose) -> void:
	horde = horde_
	windrose = windrose_


func init_neighbours() -> void:
	var windroses = Catalog.windrose_to_direction.keys()
	var origin_index = windroses.find(windrose)
	var first_index = (origin_index + 1) % windroses.size()
	var first_sector = horde.windrose_to_sector[windroses[first_index]]
	var second_index = (origin_index - 1 + windroses.size()) % windroses.size()
	var second_sector = horde.windrose_to_sector[windroses[second_index]]
	sectors.append(first_sector)
	sectors.append(second_sector)
	first_sector.diagonal_to_sector[self] = second_sector
	second_sector.diagonal_to_sector[self] = first_sector
	
	var previous_col = second_sector.cols.back()
	var next_col = first_sector.cols.front()
	next_col.clockwise_to_col[false] = previous_col
	previous_col.clockwise_to_col[true] = next_col
