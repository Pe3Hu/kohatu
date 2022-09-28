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
	var arr = {}
	var flag = {}
	var color = {}
	
	func _init(input_):
		num.index = Global.num.primary_key.knot
		Global.num.primary_key.knot += 1
		num.ring = -1
		vec.grid = input_.grid
		vec.pos = input_.pos
		arr.edge = []
		arr.slot = []
		arr.neighbour = []
		flag.avaliable = true
		flag.visiable = false
		color.current = Color(0.0, 1.0, 0.0)

class Edge:
	var num = {}
	var arr = {}
	var flag = {}
	var color = {}
	
	func _init(input_):
		num.index = Global.num.primary_key.edge
		Global.num.primary_key.edge += 1
		num.ring = -1
		num.type = input_.type
		arr.knot = input_.knots
		arr.slot = []
		arr.point = []
		flag.avaliable = true
		flag.visiable = false
		color.current = Color(1.0, 0.0, 0.0)
		
		for knot in arr.knot:
			arr.point.append(knot.vec.pos)
			knot.arr.edge.append(self)

class Slot:
	var num = {}
	var vec = {}
	var arr = {}
	var flag = {}
	var color = {}
	var obj = {}
	
	func _init(input_):
		num.index = Global.num.primary_key.slot
		Global.num.primary_key.slot += 1
		num.ring = -1
		vec.grid = input_.grid
		arr.knot = input_.knots
		flag.avaliable = true
		flag.visiable = false
		flag.blocked = false
		color.current = Color(0.0, 0.0, 0.0)
		arr.point = []
		arr.edge = []
		arr.neighbour = []
		obj.capsule = null
		
		for knot in arr.knot:
			arr.point.append(knot.vec.pos)
			knot.arr.slot.append(self)
		
		for knot in arr.knot:
			for edge in knot.arr.edge:
				for knot_ in arr.knot:
					if knot_ != knot:
						if edge.arr.knot.has(knot_) && !arr.edge.has(edge):
							arr.edge.append(edge)
		
		for edge in arr.edge:
			edge.arr.slot.append(self)

	func set_capsule(capsule_):
		flag.visiable = true
		flag.avaliable = false
		obj.capsule = capsule_
		var h = 1/360
		var s = 1
		var v = 1
		
		match obj.capsule.word.role:
			"Accumulator":
				h *= 60
			"Processor":
				h *= 0
			"Cable":
				h *= 120
			"Insulation":
				h *= 240
		
		color.current = Color().from_hsv(h, s, v)  

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
		knots_neighbours()
		slots_neighbours()
		init_knot_rings()

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
			Vector2(0,1),
			Vector2(1,1)
			]
		]
		
		var _i = 0 
		
		for knots in arr.knot:
			var edges = [[],[]]
			var _j = _i%2
			
			for knot in knots:
				for _t in types.size():
					for type in types[_t]:
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
							edges[_t].append(edge)
			
			if edges[0].size() > 0:
				arr.edge.append(edges[0])
			if edges[1].size() > 0:
				arr.edge.append(edges[1])
				
			_i += 1

	func init_slots():
		for _i in Global.num.slot.rows:
			arr.slot.append([])
			
			for _j in Global.num.slot.cols:
				var input = {}
				input.grid = Vector2(_j,_i)
				input.knots = get_knots_by_vector(input.grid)
				var slot = Classes_Scheme.Slot.new(input)
				arr.slot[_i].append(slot)

	func init_slot_rings():
		var x = Global.num.slot.cols/2
		var y = Global.num.slot.rows/2
		var start_slot = arr.slot[y][x]
		var next = []
		var current = [start_slot]
		var ring = 0
		
		#start_slot.color.current = Color(0.0, 1.0, 0.0)
		var counter = Global.num.knot.rows
		
		while counter > 0:
			for slot in current:
				slot.num.ring = ring
				
				for neighbour in slot.arr.neighbour:
					if neighbour.num.ring == -1 && !next.has(neighbour):
						next.append(neighbour)
			
			current = []
			current.append_array(next)
			next = []
			counter -= 1
		
		for slots in arr.slot:
			for slot in slots:
				if slot.num.ring != -1:
					for knot in slot.arr.knot:
						knot.num.ring = slot.num.ring
						knot.flag.visiable = true
					
					for edge in slot.arr.edge:
						edge.num.ring = slot.num.ring
						edge.flag.visiable = true
					
					slot.flag.visiable = true

	func init_knot_rings():
		var n = Global.num.knot.n-1
		var start = arr.knot[n][n]
		var next = []
		var current = [start]
		var ring = 0
		
		while ring < n:
			for knot in current:
				knot.num.ring = ring
				
				for neighbour in knot.arr.neighbour:
					if neighbour.num.ring == -1 && !next.has(neighbour):
						next.append(neighbour)
				
				
				for slot in knot.arr.slot:
					if slot.num.ring != -1:
						slot.num.ring = ring
						slot.flag.avaliable = true
				
				for edge in knot.arr.edge:
					if edge.num.ring != -1:
						edge.num.ring = ring
						edge.flag.avaliable = true
					
				knot.flag.avaliable = true
			
			current = []
			current.append_array(next)
			next = []
			ring += 1
			
			
		
		for slots in arr.slot:
			for slot in slots:
				if slot.num.ring == 1:
					slot.flag.visiable  = true

	func knots_neighbours():
		for knots in arr.knot:
			for knot in knots:
				for edge in knot.arr.edge:
					for neighbour in edge.arr.knot:
						if neighbour != knot:
							knot.arr.neighbour.append(neighbour)

	func slots_neighbours():
		for slots in arr.slot:
			for slot in slots:
				for edge in slot.arr.edge:
					for neighbour in edge.arr.slot:
						if neighbour != slot:
							slot.arr.neighbour.append(neighbour)

	func get_knots_by_index(triangle_index_):
		var m = Global.num.slot.rows
		var y = (triangle_index_/2)/m
		var x = (triangle_index_/2)%m
		var a = Vector2()
		var b = Vector2()
		var c = Vector2()
		
		if y % 2 == 0:
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
		
		for vec in vecs:
			if chec_knot(vec):
				results.append(arr.knot[vec.y][vec.x])
		
		return results

	func get_knots_by_vector(triangle_vector_):
		var y = int(triangle_vector_.y)
		var x = int(triangle_vector_.x/2)
		var _x = int(triangle_vector_.x)%2
		var a = Vector2()
		var b = Vector2()
		var c = Vector2()
		
		if y % 2 == 0:
			a = Vector2(x,y)
			b = Vector2(x,y+1)
			c = Vector2(x+1,y)
			
			if _x % 2 == 1:
				a.x += 1
				a.y += 1
		else:
			a = Vector2(x,y+1)
			b = Vector2(x,y)
			c = Vector2(x+1,y+1)
			
			if _x % 2 == 1:
				a.y -= 1
				a.x += 1
			
		var vecs = [a,b,c]
		var results = []
		
		for vec in vecs:
			if chec_knot(vec):
				results.append(arr.knot[vec.y][vec.x])
		
		return results

	func chec_knot(grid_):
		return grid_.y >= 0 && grid_.x >= 0 && grid_.y < Global.num.knot.rows && grid_.x < Global.num.knot.cols

	func chec_slot(grid_):
		return grid_.y >= 0 && grid_.x >= 0 && grid_.y < Global.num.slot.rows && grid_.x < Global.num.slot.cols

	func roll_draft(draft_):
		var options = []
		
		for slots in arr.slot:
			for slot in slots:
				if slot.num.ring == 0:
					options.append(slot)
		
		#print(options.size())
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, options.size()-1)
		var input = {}
		input.role = "Processor"
		var capsule = Classes_Scheme.Capsule.new(input)
		options[index_r].set_capsule(capsule)
