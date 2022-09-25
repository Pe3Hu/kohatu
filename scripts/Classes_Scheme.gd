extends Node


class Draft:
	var word = {}
	var obj = {}
	var dict = {}
	
	func _init(input_):
		dict.count = {}
		dict.restriction = {}
		
		for name in Global.dict.capsule.name:
			dict.count[name] = 0
		
		for key in input_.num.keys():
			dict.count[key] = input_.num[key]
		
		for key in input_.word.keys():
			dict.restriction[key] = input_.word[key]
		
		print(dict)

class Capsule:
	var num = {}
	var word = {}
	var obj = {}
	
	func _init(input_):
		#Accumulator Processor Cable Insulation
		word.role = input_.role
		pass

class Scheme:
	var num = {}
	var word = {}
	var obj = {}
	
	func _init():
		pass
