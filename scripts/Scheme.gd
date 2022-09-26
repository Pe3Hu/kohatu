extends Node2D


func _draw():
	
#	for slots in Global.obj.scheme.arr.slot:
#		for slot in slots:
#			draw_polygon(slot.arr.point, PoolColorArray([slot.color.current]))
#
#	for knots in Global.obj.scheme.arr.knot:
#		for knot in knots:
#			draw_circle(knot.vec.pos, 3, knot.color.current)
	
	draw_circle(Global.vec.window_size.center, 3, Color(0.0, 0.0, 0.0))
	
	
	for edges in Global.obj.scheme.arr.edge:
		for edge in edges:
			draw_line(edge.arr.point[0], edge.arr.point[1], Color(255, 0, 0), 1)
	


