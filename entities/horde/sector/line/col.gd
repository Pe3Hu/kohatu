extends Node2D
class_name Col


var sector: Sector
var index: int
var sites: Array[Site]
var insects: Array[Insect]

var clockwise_to_col: Dictionary


func setup(sector_: Sector, index_: int) -> void:
	sector = sector_
	index = index_

func shift(windrose_: Bozo.Windrose) -> void:
	var shift_direction = Catalog.windrose_to_direction[windrose_]
	var sector_direction = Catalog.windrose_to_direction[windrose_]
	
	if Catalog.is_parallel(shift_direction, sector_direction):
		var along_direction = shift_direction == sector_direction
		parallel_shift(along_direction)
	

func parallel_shift(along_: bool) -> void:
	insects.sort_custom(func (a, b): sites.find(a.site) > sites.find(b.site))
	
	if along_:
		#for _i in range(0, sites.size() - 1, 1):
		#	var site = sites[_i]
		#	if site.insect:
		#		site.insect.intent_backward()
		for insect in insects:
			insect.intent_backward()
	else:
		#for _i in range(0, sites.size() - 1, 1):
		#	var site = sites[_i]
		#	if site.insect:
		#		site.insect.intent_forward()
		for insect in insects:
			insect.intent_forward()
