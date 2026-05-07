extends Node
class_name EnemyController

var enemies = []

func get_penalty() -> int:
	return enemies.size()
