extends Node2D
class_name Magistral


var hull: Hull
var type: Bozo.Magistral
var coord: Vector2i

var capsules: Array[Capsule]


func setup(hull_: Hull, coord_: Vector2i, type_: Bozo.Magistral):
	hull = hull_
	coord = coord_
	type = type_

func highligh_capsules() -> void:
	for capsule in capsules:
		capsule.status = Bozo.Capsule.MIDDLE
