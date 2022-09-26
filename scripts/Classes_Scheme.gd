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

class Knot:
	var num = {}
	var vec = {}
	var flag = {}
	var color = {}
	
	func _init(input_):
		num.index = Global.num.primary_key.knot
		Global.num.primary_key.knot += 1
		num.ring = -1
		vec.grid = input_.grid
		vec.pos = input_.pos
		flag.avaliable = true
		flag.visiable = true
		color.current = Color(1.0, 1.0, 1.0)

class Edge:
	var num = {}
	var arr = {}
	
	func _init(input_):
		num.index = Global.num.primary_key.edge
		Global.num.primary_key.edge += 1
		num.type = input_.type
		arr.knot = input_.knots
		arr.slot = []
		arr.point = []
		
		for knot in arr.knot:
			arr.point.append(knot.vec.pos)
	
	func add_slot(slot_):
		arr.slot.append(slot_)

class Slot:
	var num = {}
	var vec = {}
	var arr = {}
	var flag = {}
	var color = {}
	
	func _init(input_):
		num.index = Global.num.primary_key.slot
		Global.num.primary_key.slot += 1
		num.ring = -1
		vec.grid = input_.grid
		arr.knot = input_.knots
		flag.avaliable = true
		flag.visiable = true
		color.current = Color(0.0, 0.0, 1.0)
		arr.point = []
		
		for knot in arr.knot:
			arr.point.append(knot.vec.pos)

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
	var arr = {}
	var obj = {}
	
	func _init():
		arr.knot = []
		arr.edge = []
		arr.slot = []
		
		init_knots()
		init_edges()
		init_slots()
		#init_neighbours()
		

	func init_knots():
		for _i in Global.num.knot.rows:
			arr.knot.append([])
			
			var vec = Vector2(0,_i*Global.num.scheme.h)
			vec += Global.vec.scheme.offset
			
			if _i % 2 == 1:
				vec.x += 0.5*Global.num.scheme.a
			
			for _j in Global.num.knot.cols:
				var input = {}
				input.pos = vec
				input.grid = Vector2(_j,_i)
				var knot = Classes_Scheme.Knot.new(input)
				arr.knot[_i].append(knot)
				vec.x += Global.num.scheme.a

	func init_edges():
		var types = [[0],[1,2]]
		var shifts = [
			[
			Vector2(1,0),
			Vector2(-1,1),
			Vector2(0,1)
			],
			[
			Vector2(1,0),
			Vector2(1,1),
			Vector2(0,1)
			]
		]
		
		var _i = 0 
		
		for knots in arr.knot:
			var _j = _i%2
			
			for types_ in types:
				var edges = []
				
				for type in types_:
					for knot in knots:
						var begin = knot.vec.grid
						var shift = shifts[_j][type]
						var end = begin + shift
						
						if chec_knot(end):
							var input = {}
							input.knots = []
							input.knots.append(arr.knot[begin.y][begin.x])
							input.knots.append(arr.knot[end.y][end.x])
							input.type = type
							var edge = Classes_Scheme.Edge.new(input)
							edges.append(edge)
							
				arr.edge.append(edges)
				
			_i += 1

	func init_slots():
		for _i in Global.num.slot.rows:
			arr.slot.append([])
			
			for _j in Global.num.slot.cols:
				var input = {}
				input.grid = Vector2(_j,_i)
				input.knots = Global.get_knots_by_vector(arr.knot,input.grid)
				var slot = Classes_Scheme.Slot.new(input)
				arr.slot[_i].append(slot)

	func init_neighbours():
		var x = Global.num.slot.cols/2
		var y = Global.num.slot.rows/2
		var start_slot = arr.slot[y][x]
		var ring = 0
		
		#start_slot.color.current = Color(0.0, 1.0, 0.0)
		
		start_slot.num.ring = ring
		var vertexs = []
		for knot in start_slot.arr.knot:
			pass


	func get_knots_by_index(knots,triangle_index_):
		var m = num.knot.rows-1
		var x = (triangle_index_/2)/m
		var y = (triangle_index_/2)%m
		var a = Vector2()
		var b = Vector2()
		var c = Vector2()
		
		if x % 2 == 0:
			a = Vector2(x,y)
			b = Vector2(x,y+1)
			c = Vector2(x+1,y)
			
			if triangle_index_ % 2 == 1:
				a.x += 1
				a.y += 1
		else:
			a = Vector2(x,y+1)
			b = Vector2(x,y)
			c = Vector2(x+1,y+1)
			
			if triangle_index_ % 2 == 1:
				a.y -= 1
				a.x += 1
			
		var vecs = [a,b,c]
		var results = []
		var f = Global.obj
		
		for vec in vecs:
			results.append(knots[vec.y][vec.x])
		
		return results

	func get_knots_by_vector(knots, triangle_vector_):
		var m = (num.knot.cols-1)*2
		var index = int(triangle_vector_.y*m + triangle_vector_.x)
		return get_knots_by_index(knots, index)

	func get_knot_by_grid():
		pass

	func chec_knot(grid_):
		return grid_.y >= 0 && grid_.x >= 0 && grid_.y < Global.num.knot.rows && grid_.x < Global.num.knot.cols


