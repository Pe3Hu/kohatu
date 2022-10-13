extends Node


class Region:
	var num = {}
	var word = {}
	var vec = {}
	var arr = {}
	var obj = {}
	
	func _init(input_):
		num.index = Global.num.primary_key.region
		Global.num.primary_key.region += 1
		obj.terrain = input_.terrain
		vec.corner = input_.corner
		num.cols = input_.cols
		num.rows = input_.rows
		arr.sector = input_.sectors
		
		for sector in arr.sector:
			sector.obj.region = self

class Lode:
	var num = {}
	var word = {}
	var vec = {}
	var arr = {}
	var obj = {}
	
	func _init(input_):
		num.index = Global.num.primary_key.lode
		Global.num.primary_key.lode += 1
		obj.terrain = input_.terrain
		vec.grid = input_.grid
		num.bulk = {}
		num.bulk.value = 0
		num.d = {}
		num.noise = {}
		num.mix = {}
		arr.sector = []
		set_type()

	func set_type():
		var center = obj.terrain.num.lode.n/2
		
		if vec.grid.x == center && vec.grid.y == center:
			word.type = "Center"
		else:
			var x_left = vec.grid.x == 0
			var x_right = vec.grid.x == obj.terrain.num.lode.n-1
			var y_top = vec.grid.y == 0
			var y_bot = vec.grid.y == obj.terrain.num.lode.n-1
			
			if (x_left || x_right) && (y_top || y_bot):
				word.type = "Corner"
			else:
				word.type = "Edge"
		
		num.bulk.parts = Global.dict.lode.bulk[str(obj.terrain.num.lode.n)][word.type]

	func norm():
		num.d.min = obj.terrain.num.sector.cols+obj.terrain.num.sector.rows
		num.d.max = -1
		
		for sector in arr.sector:
			var d = sector.get_nearest_d()
			
			if d < num.d.min:
				num.d.min = d
			if d > num.d.max:
				num.d.max = d
		
		num.noise.min = 1
		num.noise.max = 0
		
		for sector in arr.sector:
			if sector.num.noise < num.noise.min:
				num.noise.min = sector.num.noise
			if sector.num.noise > num.noise.max:
				num.noise.max = sector.num.noise
		
		for sector in arr.sector:
			sector.num.hue.lode = num.index/pow(obj.terrain.num.lode.n,2)
			sector.num.saturation.lode = 1-sector.get_nearest_d()/(num.d.min+num.d.max)
			sector.num.saturation.noise = (sector.num.noise-num.noise.min)/(num.noise.max-num.noise.min)
			
			var value = {}
			value.lode = sector.num.saturation.lode
			value.noise = sector.num.saturation.noise
			var scale = {}
			scale.lode = 1.0
			scale.noise = 1.0
			sector.num.saturation.mix = (value.lode*scale.lode+value.noise*scale.noise)/(scale.lode+scale.noise)
#
#		num.mix.min = 1
#		num.mix.max = 0
#
#		for sector in arr.sector:
#			if sector.num.saturation.mix < num.mix.min:
#				num.mix.min = sector.num.noise
#			if sector.num.saturation.mix > num.mix.max:
#				num.mix.max = sector.num.noise
#
#		for sector in arr.sector:
#			sector.num.saturation.mix = (sector.num.saturation.mix-num.mix.min)/(num.mix.max-num.mix.min)
		pass

	func fill_sectors():
		var options = [obj.origin]
		var filled = []
		var part = num.bulk.value/Global.dict.lode.fullness["Total"]
		var values = []
		var sectors = []
		
		for _i in Global.dict.lode.fullness["Count"].size():
			for _j in Global.dict.lode.fullness["Count"][_i]:
				var option = {}
				values.append(Global.dict.lode.fullness["Value"][_i])
#				Global.rng.randomize()
#				var index_r = Global.rng.randi_range(0,options.size()-1)
#				option.sector = options[index_r]
#				option.value = options[index_r].num.saturation.mix
				option.sector = options[0]
				option.value = options[0].num.saturation.mix

				for option_ in options:
					if option_.num.saturation.mix > option.sector.num.saturation.mix:
						option.sector = option_
						option.value = option_.num.saturation.mix
				
				while options.has(option.sector):
					options.erase(option.sector)
				
				filled.append(option.sector)
				sectors.append(option)
				option.sector.num.bulk = 0.1
				
				for neighbour in option.sector.arr.neighbour:
					if neighbour.num.bulk == 0 && neighbour.obj.lode == self && neighbour.flag.borderland:
						var count = 1
						#var count = int(neighbour.num.saturation.mix*10)
						
						for _k in count:
							options.append(neighbour)
			
		sectors.sort_custom(Classes_Planete.Sorter, "sort_descending")
		
		for _i in sectors.size():
			sectors[_i].sector.num.bulk = part*values[_i]
			sectors[_i].sector.num.saturation.bulk = float(values[_i])/values[0]

class Sector:
	var num = {}
	var vec = {}
	var obj = {}
	var arr = {}
	var word = {}
	var flag = {}
	var color = {}

	func _init(input_):
		vec.grid = input_.grid
		obj.terrain = input_.terrain
		num.noise = input_.noise
		arr.vertex = []
		arr.neighbour = []
		vec.center = Vector2()
		num.hue = {}
		num.saturation = {}
		num.saturation.bulk = 0
		num.brightness  = {}
		num.bulk = 0
		set_borderland()
		obj.region = null
		
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
		obj.lode = null
		num.lode.d = {}
		var n = obj.terrain.num.lode.n*obj.terrain.num.lode.n
		
		for _i in n:
			num.lode.d[_i] = -1

	func resize_noise(size_):
		num.noise -= size_.min
		num.noise /= size_.l

	func set_biom(biom_):
		word.biom = biom_

	func get_color():
		var h = 1.0/360
		var s = 1.0
		var v = 1.0
		var layer = Global.arr.layer[obj.terrain.num.index.layer]
		
		match layer:
			"Bulk":
				h = num.hue.lode
				s = num.saturation.bulk
			"Mix":
				h = num.hue.lode
				s = num.saturation.mix
			"Noise":
				v = num.noise
				s = 0
				h = 0
			"Lode":
				h = num.hue.lode
				s = num.saturation.lode
			"Region":
				s = 0
				v = float(obj.region.num.index%2+1)/3
				
				if obj.region.num.index == Global.num.primary_key.region-1:
					v = 0.5
		
#		if obj.lode != - 1:
#			if num.lode.d[obj.lode] == 0:
#				s = 1.0
		
		color.current = Color().from_hsv(h, s, v)
		return color.current

	func get_nearest_d():
		return num.lode.d[obj.lode]

	func fill_lode(sectors_):
		for key in sectors_.keys():
			var sector = sectors_[key]
			var x = abs(sector.vec.grid.x-vec.grid.x)
			var y = abs(sector.vec.grid.y-vec.grid.y)
			num.lode.d[key] = x+y

	func find_nearest_lode():
		var d = obj.terrain.num.sector.cols+obj.terrain.num.sector.rows
		obj.lode = null
		
		for key in num.lode.d.keys():
			if num.lode.d[key] != -1 && num.lode.d[key] <= d:
				obj.lode = key
				d = num.lode.d[key]
		
		obj.lode.arr.sector.append(self)

	func set_borderland():
		var border = 3
		var x = vec.grid.x >= border && vec.grid.x < obj.terrain.num.sector.cols-border
		var y = vec.grid.y >= border && vec.grid.y < obj.terrain.num.sector.cols-border
		flag.borderland = x && y

class Terrain:
	var num = {}
	var arr = {}
	var vec = {}
	var obj = {}

	func _init(input_):
		num.index = {}
		num.index.layer = 0
		num.lode = {}
		num.sector = {}
		num.sector.cols = input_.cols
		num.sector.rows = input_.rows
		num.lode.n = input_.n
		num.lode.bulk = input_.bulk
		arr.sector = []
		arr.lode = []
		arr.region = []
		vec.center = Vector2(
			num.sector.cols/2,
			num.sector.rows/2
			)
		
		update_offset()
		reload_noise()
		init_sectors()
		calc_noise()
		init_lodes()
		init_regions()

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
		
		for sectors in arr.sector:
			for sector in sectors:
				for neighbour in Global.arr.neighbour:
					var grid = sector.vec.grid + neighbour
					
					if sector_border_check(grid):
						if !sector.arr.neighbour.has(arr.sector[grid.y][grid.x]):
							sector.arr.neighbour.append(arr.sector[grid.y][grid.x])
							arr.sector[grid.y][grid.x].arr.neighbour.append(sector)

	func calc_noise():
		var size = {}
		size.min = 1
		size.max = -1
		
		for sectors in arr.sector:
			for sector in sectors:
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
		var rand_i = 0
		var sectors_ = {}
		var types = {}
		var parts = 0
		
		for _i in num.lode.n:
			var y = first + (second + third)*_i
			
			for _j in num.lode.n:
				var input = {}
				Global.rng.randomize()
				var rand_x = Global.rng.randi_range(0,second-1)
				var x = first + (second + third)*_j 
				Global.rng.randomize()
				var rand_y = Global.rng.randi_range(0,second-1)
				input.origin = Vector2(x + rand_x,y + rand_y)
				input.grid = Vector2(_j,_i)
				input.terrain = self
				var lode = Classes_Terrain.Lode.new(input)
				arr.lode.append(lode)
				
				if !types.keys().has(lode.word.type):
					types[lode.word.type] = [lode]
				else:
					types[lode.word.type].append(lode)
				
				lode.obj.origin = arr.sector[input.origin.y][input.origin.x]
				lode.obj.origin.num.lode.d[lode.num.index] = 0
				sectors_[lode] = lode.obj.origin
				parts += lode.num.bulk.parts
		
		for type in types.keys():
			if type != "Center":
				Global.rng.randomize()
				var index_r = Global.rng.randi_range(0, types[type].size()-1)
				var lode = types[type][index_r]
				lode.num.bulk.parts += Global.dict.lode.bulk[str(num.lode.n)]["Overflow"]
				parts += Global.dict.lode.bulk[str(num.lode.n)]["Overflow"]
		
		for lode in arr.lode:
			lode.num.bulk.value = num.lode.bulk/parts*lode.num.bulk.parts
		
		for sectors in arr.sector:
			for sector in sectors:
				sector.fill_lode(sectors_)
		
		for sectors in arr.sector:
			for sector in sectors:
				sector.find_nearest_lode()
		
		for lode in arr.lode:
			lode.norm()
			lode.fill_sectors()

	func init_regions():
		var n = 3
		var input = {}
		input.rows = n
		input.cols = n
		input.terrain = self
		var rows = num.sector.rows/n-2
		var cols = num.sector.cols/n-2
		
		for _i in rows:
			for _j in cols:
				input.corner = Vector2((_j+1)*n,(_i+1)*n)
				input.sectors = []
				
				for _y in input.rows:
					for _x in input.cols:
						var sector = arr.sector[input.corner.y+_y][input.corner.x+_x]
						input.sectors.append(sector)
				
				var region = Classes_Terrain.Region.new(input)
				arr.region.append(region)
		
		input.corner = Vector2()
		input.sectors = []
		
		for sectors in arr.sector:
			for sector in sectors:
				if sector.obj.region == null:
					input.sectors.append(sector)
		
		var region = Classes_Terrain.Region.new(input)
		arr.region.append(region)

	func next_layer():
		num.index.layer = (num.index.layer+1)%Global.arr.layer.size()

	func sector_border_check(vec_):
		return vec_.x >= 0 && vec_.x < num.sector.cols && vec_.y >= 0 && vec_.y < num.sector.rows
