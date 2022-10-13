extends Node


func init_nulls():
	#Array generate( int n, double w, double h, int seed )
	#Array generate_from_points( Vector2Array points, double w, double h ) 
	#var a = Delaunay.new()
	var input = {}
	input.num = {}
	input.num["Accumulator"] = 1
	input.num["Processor"] = 1
	input.word = {}
	input.word["Cable"] = "Min"
	input.word["Insulation"] = "Min"
	var draft = Classes_Project.Draft.new(input)
	
	Global.obj.scheme = Classes_Project.Project.new()
	Global.obj.scheme.roll_draft(draft)
	
	input = {}
	input.cols = 27
	input.rows = 27
	input.n = 3
	input.bulk = 78000.0
	Global.obj.terrain = Classes_Terrain.Terrain.new(input)

func _ready():
#	var txt = "c4eeec20ece8ebfbe920e4eeec0a"
#	var data = Global.conver16(txt)
#	var path = "res://json/"
#	var name_ = "16"
#	Global.save_json(data,path,name_)
	init_nulls()

func _input(event):
	if event is InputEventMouseButton:
		if Global.flag.click:
			Global.flag.click = !Global.flag.click
			Global.obj.terrain.next_layer()
		else:
			Global.flag.click = !Global.flag.click

func _on_Timer_timeout():
	Global.node.TimeBar.value +=1
	
	if Global.node.TimeBar.value >= Global.node.TimeBar.max_value:
		Global.node.TimeBar.value -= Global.node.TimeBar.max_value
