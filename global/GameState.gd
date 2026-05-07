extends Node


var heat: int = 0
var ore: int = 0
var movement: int = 0
var scan: int = 0


func change_heat(value_: int):
	heat += value_

func change_ore(value_: int):
	ore += value_

func change_movement(value_: int):
	movement += value_

func change_scan(value_: int):
	scan += value_
