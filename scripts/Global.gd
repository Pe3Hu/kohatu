extends Node


var rng = RandomNumberGenerator.new()
var noise = OpenSimplexNoise.new()
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
	num.knot.n = 5
	num.knot.rows = num.knot.n*2-1
	num.knot.cols = num.knot.n*2-1
	
	num.project = {}
	num.project.a = 24
	num.project.h = sqrt(3)*num.project.a/2
	
	num.slot = {}
	num.slot.rows = num.knot.rows-1
	num.slot.cols = (num.knot.cols-1)*2
	
	num.sector = {}
	num.sector.a = 24

func init_primary_key():
	num.primary_key = {}
	num.primary_key.knot = 0
	num.primary_key.edge = 0
	num.primary_key.slot = 0
	num.primary_key.lode = 0
	num.primary_key.region = 0

func init_dict():
	dict.capsule = {}
	dict.capsule.name = ["Accumulator", "Processor", "Cable", "Insulation"]
	
	dict.ressource = {}
	dict.ressource.type = {
		"Technology": ["Specimen","Concept","Project"],
		"Manufacture": ["Raw","Bullion","Module"],
		"Reconnaissance": ["Data","Fact","Decree"]
	}
	
	dict.module = {}
	dict.module.job = {
		"Drilling": {
			"Input": ["Terrain"],
			"Output": ["Raw"]
		},
		"Carting": {
			"Input": ["Raw","Bullion","Specimen"],
			"Output": ["Raw","Bullion","Specimen"]
		},
		"Keeping": {
			"Input": ["Raw","Bullion","Specimen"],
			"Output": ["Raw","Bullion","Specimen"]
		},
		"Melting": {
			"Input": ["Raw"],
			"Output": ["Bullion"]
		},
		"Integration": {
			"Input": ["Bullion"],
			"Output": ["Module"]
		},
		"Gathering": {
			"Input": ["Terrain"],
			"Output": ["Specimen"]
		},
		"Scrutinizing": {
			"Input": ["Specimen"],
			"Output": ["Concept"]
		},
		"Testing": {
			"Input": ["Concept"],
			"Output": ["Project"]
		},
		"Retention": {
			"Input": ["Terrain"],
			"Output": ["Terrain"]
		},
		"Liquidation": {
			"Input": ["Terrain"],
			"Output": ["Terrain"]
		},
		"Scouting": {
			"Input": ["Terrain"],
			"Output": ["Data"]
		},
		"Revise": {
			"Input": ["Data"],
			"Output": ["Fact"]
		},
		"Prognostication": {
			"Input": ["Fact"],
			"Output": ["Decree"]
		},
		"Planning": {
			"Input": ["Decree"],
			"Output": ["Plan"]
		},
		"Assembling": {
			"Input": ["Project","Module"],
			"Output": ["Drone","Drone"]
		},
		"Broadcasting": {
			"Input": ["Terrain"],
			"Output": ["Terrain"]
		},
		"Chassis": {
			"Input": ["Drone"],
			"Output": ["Drone"]
		}
	}
	dict.drone.job = {
		"Driller": "Drilling",
		"Carter": "Carting", 
		"Keeper": "Keeping",
		"Melter": "Melting",
		"Integrator": "Integration",
		"Gatherer": "Gathering",
		"Scrutinizer": "Scrutinizing",
		"Tester": "Testing",
		"Retentor": "Retention",
		"Liquidator": "Liquidation",
		"Scouter": "Scouting",
		"Reviser": "Revise",
		"Prognosticator": "Prognostication",
		"Planner": "Planning",
		"Assember": "Assembling",
		"Broadcaster": "Broadcasting"
	}
	
	dict.lode = {}
	dict.lode.bulk = {
		"3": {
			"Edge": 6,
			"Corner": 9,
			"Center": 12,
			"Overflow": 3
		}
	}
	dict.lode.fullness = {
		"Value": [10,6,3,1],
		"Count": [1,2,3,4],
#		"Value": [11,7,5,3,2],
#		"Count": [1,2,3,4,5],
		"Total": 0
	}
	
	for _i in dict.lode.fullness["Value"].size():
		dict.lode.fullness["Total"] += dict.lode.fullness["Count"][_i]*dict.lode.fullness["Value"][_i]

func init_arr():
	arr.sequence = {} 
	arr.sequence["A000040"] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
	arr.sequence["A000045"] = [89, 55, 34, 21, 13, 8, 5, 3, 2, 1, 1]
	arr.sequence["A000124"] = [7, 11, 16] #, 22, 29, 37, 46, 56, 67, 79, 92, 106, 121, 137, 154, 172, 191, 211]
	arr.sequence["A001358"] = [4, 6, 9, 10, 14, 15, 21, 22, 25, 26]
	
	arr.vertex = [
		Vector2(1,0),
		Vector2(1,1),
		Vector2(0,1),
		Vector2(0,0)
	]
	
	arr.neighbour = [
		Vector2(1,0),
		Vector2(0,1),
		Vector2(-1,0),
		Vector2(0,-1)
	]
	arr.layer = ["Region","Bulk"]#["Mix"]#,"Lode","Mix",Noise
	

func init_node():
	node.TimeBar = get_node("/root/Game/TimeBar") 
	node.Game = get_node("/root/Game") 

func init_flag():
	flag.click = false
	flag.grid = {}
	flag.grid.odd = true

func init_vec():
	init_window_size()
	
	vec.project = {}
	vec.project.offset = vec.window_size.center
	vec.project.offset.x -= (num.knot.cols-1) * num.project.a / 2
	vec.project.offset.y -= (num.knot.rows-1) * num.project.h / 2
	
	if num.knot.n % 2 == 0:
		vec.project.offset.x -= num.project.a / 2
	
	vec.terrain = {}
	vec.terrain.offset = vec.window_size.center

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
