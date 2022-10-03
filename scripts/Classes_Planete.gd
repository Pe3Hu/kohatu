extends Node


class Planete:
	var num = {}
	var arr = {}
	var obj = {}
	
	func _init():
		arr.serveur = []

class Sorter:
	static func sort_ascending(a, b):
		if a.value < b.value:
			return true
		return false

	static func sort_descending(a, b):
		if a.value > b.value:
			return true
		return false
