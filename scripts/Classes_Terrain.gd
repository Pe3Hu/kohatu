extends Node


class Lode:
	var num = {}
	var arr = {}
	var obj = {}
	
	func _init(input_):
		num.bulk = input_.bulk
		arr.sector = input_.sector

class Sector:
	var num = {}
	var vec = {}
	var obj = {}
	var arr = {}
	var word = {}
	var color = {}
	
	func _init(input_):
		vec.grid = input_.grid
		obj.terrain = input_.terrain
		num.noise = input_.noise
		arr.vertex = []
		vec.center = Vector2()
		
		for vertex in Global.arr.vertex:
			var pos = Vector2(
				vec.grid.x + vertex.x,
				vec.grid.y + vertex.y
				)
			pos *= Global.num.sector.a
			pos += Global.vec.terrain.offset
			arr.vertex.append(pos)
			vec.center += pos/Global.arr.vertex.size()
		
		num.lode = {}
		num.lode.current = -1
		num.lode.d = {}
		var n = obj.terrain.num.lode.n*obj.terrain.num.lode.n
		
		for _i in n:
			num.lode.d[_i] = -1

	func resize_noise(size_):
		num.noise -= size_.min
		num.noise /= size_.l

	func set_biom(biom_):
		word.biom = biom_
		var h = 1.0/360
		var s = 1.0
		var v = 1.0
		
		match word.biom:
			"0":
				h *= 60
			"1":
				h *= 0
			"2":
				h *= 120
			"3":
				h *= 240
		#h *= (vec.grid.x + vec.grid.y*10)/(100)*360
		s *= 0
		h *= 360 *int(num.lode.current)/9
		s = num.noise
		
		if num.lode.current != - 1:
			if num.lode.d[num.lode.current] == 0:
				s = 1.0
		color.current = Color().from_hsv(h, s, v)

	func get_nearest_d():
		return num.lode.d[num.lode.current]

	func fill_lode(sectors_):
		for key in sectors_.keys():
			var sector = sectors_[key]
			var x = abs(sector.vec.grid.x-vec.grid.x)
			var y = abs(sector.vec.grid.y-vec.grid.y)
			num.lode.d[key] = max(x,y)

	func find_nearest_lode():
		var d = obj.terrain.num.sector.cols+obj.terrain.num.sector.rows
		num.lode.current = -1
		
		for key in num.lode.d.keys():
			if num.lode.d[key] != -1 && num.lode.d[key] < d:
				num.lode.current = int(key)
				d = num.lode.d[key]
		
		set_biom("Empty")

class Terrain:
	var num = {}
	var arr = {}
	var vec = {}
	var obj = {}
	
	func _init(input_):
		num.lode = {}
		num.sector = {}
		num.sector.cols = input_.cols
		num.sector.rows = input_.rows
		num.lode.n = input_.n
		num.lode.bulk = input_.bulk
		arr.sector = []
		vec.center = Vector2(
			num.sector.cols/2,
			num.sector.rows/2
			)
		
		update_offset()
		reload_noise()
		init_sectors()
		init_lodes()
		calc_noise()

	func update_offset():
		Global.vec.terrain.offset = Global.vec.window_size.center
		Global.vec.terrain.offset.x -= num.sector.cols * Global.num.sector.a / 2
		Global.vec.terrain.offset.y -= num.sector.rows * Global.num.sector.a / 2

	func reload_noise():
		Global.rng.randomize()
		Global.noise.seed = Global.rng.randi()
		Global.noise.octaves = 3
		Global.noise.period = 20.0
		Global.noise.persistence = 0.8

	func init_sectors():
		for _i in num.sector.rows:
			arr.sector.append([])
			
			for _j in num.sector.cols:
				var input = {}
				input.grid = Vector2(_j,_i)
				input.terrain = self
				input.noise = Global.noise.get_noise_2dv(input.grid)
				
				var sector = Classes_Terrain.Sector.new(input)
				arr.sector[_i].append(sector)

	func calc_noise():
		var size = {}
		size.min = 1
		size.max = -1
		var l = 3
		
		for sectors in arr.sector:
			for sector in sectors:
				var d = l - sector.get_nearest_d()
				var value = pow(d,2)/pow(l,2)
				if d < 0:
					value = 0
				sector.num.noise = (sector.num.noise + value)/2
				
				if sector.num.noise > size.max:
					size.max = sector.num.noise
				if sector.num.noise < size.min:
					size.min = sector.num.noise
		size.l = -size.min + size.max
		
		for sectors in arr.sector:
			for sector in sectors:
				sector.resize_noise(size)

	func init_lodes():
		var first = 5
		var second = 3
		var third = 4
		var lode = 0
		var rand_i = 0
		var sectors_ = {}
		
		for _i in num.lode.n:
			var y = first + (second + third)*_i
			
			for _j in num.lode.n:
				Global.rng.randomize()
				var rand_x = Global.rng.randi_range(0,second-1)
				var x = first + (second + third)*_j 
				Global.rng.randomize()
				var rand_y = Global.rng.randi_range(0,second-1)
				var grid = Vector2(x + rand_x,y + rand_y)
				arr.sector[grid.y][grid.x].num.lode.d[lode] = 0
				sectors_[lode] = arr.sector[grid.y][grid.x]
				lode += 1
		
		for sectors in arr.sector:
			for sector in sectors:
				sector.fill_lode(sectors_)
		
		for sectors in arr.sector:
			for sector in sectors:
				sector.find_nearest_lode()
