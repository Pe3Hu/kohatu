extends Node


class Ressource:
	var num = {}
	var word = {}
	var obj = {}
	
	func _init(input_):
		num.value = {}
		num.value.max = 100
		num.value.current = 0
		word.name = input_.name
		word.type = input_.type

class Module:
	var num = {}
	var word = {}
	var obj = {}
	
	func _init(input_):
		num = {}

class Drone:
	var num = {}
	var arr = {}
	var obj = {}
	
	func _init(input_):
		arr.module = [] 

class Server:
	var num = {}
	var arr = {}
	var obj = {}
	
	func _init(input_):
		arr.drone = []
