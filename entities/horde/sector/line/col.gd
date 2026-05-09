extends Node2D
class_name Col


var sector: Sector
var index: int
var sites: Array[Site]


func setup(sector_: Sector, index_: int) -> void:
	sector = sector_
	index = index_
