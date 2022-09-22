extends Node


class Null:
	var num = {}
	
	func _init(input_):
		num.index = Global.num.primary_key.null
		Global.num.primary_key.null += 1

class Sorter:
	static func sort_ascending(a, b):
		if a.value < b.value:
			return true
		return false

	static func sort_descending(a, b):
		if a.value > b.value:
			return true
		return false
