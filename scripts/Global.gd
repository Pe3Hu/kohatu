extends Node


var rng = RandomNumberGenerator.new()
var num = {}
var dict = {}
var arr = {}
var obj = {}
var node = {}
var flag = {}
var vec = {}

func init_num():
	init_primary_key()
	
	num.knot = {}
	num.knot.rows = 7
	num.knot.cols = 5
	
	num.scheme = {}
	num.scheme.a = 24
	num.scheme.h = sqrt(3)*num.scheme.a/2
	
	num.slot = {}
	num.slot.rows = num.knot.rows-1
	num.slot.cols = (num.knot.cols-1)*2

func init_primary_key():
	num.primary_key = {}
	num.primary_key.knot = 0
	num.primary_key.edge = 0
	num.primary_key.slot = 0

func init_dict():
	dict.capsule = {}
	dict.capsule.name = ["Accumulator", "Processor", "Cable", "Insulation"]

func init_arr():
	arr.sequence = {} 
	arr.sequence["A000040"] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
	arr.sequence["A000045"] = [89, 55, 34, 21, 13, 8, 5, 3, 2, 1, 1]
	arr.sequence["A000124"] = [7, 11, 16] #, 22, 29, 37, 46, 56, 67, 79, 92, 106, 121, 137, 154, 172, 191, 211]
	arr.sequence["A001358"] = [4, 6, 9, 10, 14, 15, 21, 22, 25, 26]

func init_node():
	node.TimeBar = get_node("/root/Game/TimeBar") 
	node.Game = get_node("/root/Game") 

func init_flag():
	flag.click = false
	flag.grid = {}
	flag.grid.odd = true

func init_vec():
	init_window_size()
	
	vec.scheme = {}
	vec.scheme.offset = vec.window_size.center
	vec.scheme.offset.x -= (num.knot.cols-1) * num.scheme.a / 2
	vec.scheme.offset.y -= (num.knot.rows-1) * num.scheme.h / 2

func init_window_size():
	vec.window_size = {}
	vec.window_size.width = ProjectSettings.get_setting("display/window/size/width")
	vec.window_size.height = ProjectSettings.get_setting("display/window/size/height")
	vec.window_size.center = Vector2(vec.window_size.width/2, vec.window_size.height/2)

func _ready():
	init_num()
	init_dict()
	init_arr()
	init_node()
	init_flag()
	init_vec()

func save_json(data_,file_path_,file_name_):
	var file = File.new()
	file.open(file_path_+file_name_+".json", File.WRITE)
	file.store_line(to_json(data_))
	file.close()
	print(data_)

func load_json(file_path_,file_name_):
	var file = File.new()
	
	if not file.file_exists(file_path_+file_name_+".json"):
			 #save_json()
			 return null
	
	file.open(file_path_+file_name_+".json", File.READ)
	var data = parse_json(file.get_as_text())
	return data

func conver16(txt_):
	var letters = []
	var sum = int(txt_)
	
#	for letter in txt_:
#		sum += letter
	return sum

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
