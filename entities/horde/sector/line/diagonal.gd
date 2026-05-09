extends Node2D
class_name Diagonal


var horde: Horde
var sectors: Array[Sector]
var windrose: Bozo.Windrose
var sites: Array[Site]


func setup(horde_: Horde, windrose_: Bozo.Windrose) -> void:
	horde = horde_
	windrose = windrose_
