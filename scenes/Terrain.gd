extends Node2D


func _draw():
	for sectors in Global.obj.terrain.arr.sector:
		for sector in sectors:
				draw_polygon(sector.arr.vertex, PoolColorArray([sector.color.current]))
	
	draw_circle(Global.vec.window_size.center, 3, Color(1.0, 1.0, 1.0))
