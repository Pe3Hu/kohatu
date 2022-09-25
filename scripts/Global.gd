extends Node


var rng = RandomNumberGenerator.new()
var num = {}
var dict = {}
var arr = {}
var obj = {}
var node = {}
var flag = {}

func init_num():
	init_primary_key()
	
	num.grid = {}
	num.grid.n = 3
	num.grid.rows = 2
	num.grid.cols = 3
	num.grid.a = 24
	num.grid.h = sqrt(3)*num.grid.a/2

func init_primary_key():
	num.primary_key = {}
	num.primary_key.null = 0

func init_dict():
	init_window_size()
	
	dict.capsule = {}
	dict.capsule.name = ["Accumulator", "Processor", "Cable", "Insulation"]

func init_window_size():
	dict.window_size = {}
	dict.window_size.width = ProjectSettings.get_setting("display/window/size/width")
	dict.window_size.height = ProjectSettings.get_setting("display/window/size/height")
	dict.window_size.center = Vector2(dict.window_size.width/2, dict.window_size.height/2)

func init_arr():
	arr.sequence = {} 
	arr.sequence["A000040"] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
	arr.sequence["A000045"] = [89, 55, 34, 21, 13, 8, 5, 3, 2, 1, 1]
	arr.sequence["A000124"] = [7, 11, 16] #, 22, 29, 37, 46, 56, 67, 79, 92, 106, 121, 137, 154, 172, 191, 211]
	arr.sequence["A001358"] = [4, 6, 9, 10, 14, 15, 21, 22, 25, 26]
	
	init_grid()

func init_grid():
	arr.grid = []
	
	for _i in num.grid.rows:
		arr.grid.append([])
		var vec = Vector2(0,_i*num.grid.h)
		
		if _i % 2 == 1:
			vec.x += 0.5*num.grid.a
		
		for _j in num.grid.cols:
			arr.grid[_i].append(vec)
			vec.x += num.grid.a

func init_node():
	node.TimeBar = get_node("/root/Game/TimeBar") 
	node.Game = get_node("/root/Game") 

func init_flag():
	flag.click = false
	flag.grid = {}
	flag.grid.odd = true

func _ready():
	init_num()
	init_dict()
	init_arr()
	init_node()
	init_flag()


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
