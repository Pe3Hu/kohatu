extends Resource
class_name SectorData


var windrose: Bozo.Windrose = Bozo.Windrose.N
var economy: Bozo.Economy = Bozo.Economy.NORMAL

var coords: Array[Vector2i]


func _init(windrose_: Bozo.Windrose, economy_: Bozo.Economy) -> void:
	windrose = windrose_
	economy = economy_
