extends Node2D
class_name Row


var sector: Sector
var index: int
var sites: Array[Site]

var promotion_to_row: Dictionary


func setup(sector_: Sector, index_: int) -> void:
	sector = sector_
	index = index_
