extends Node2D


func _draw():
	var center = Vector2(200, 200)
	var color = Color(1.0, 0.0, 0.0)
	var points_arc = []
	points_arc.append(Global.arr.grid[2][2])
	points_arc.append(Global.arr.grid[2][3])
	points_arc.append(Global.arr.grid[3][2])
	draw_polygon(points_arc, PoolColorArray([color]))
