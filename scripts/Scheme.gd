extends Node2D


func _draw():
#	Global.obj.scheme.arr.slot[0][0].flag.visiable = true
#	Global.obj.scheme.arr.slot[0][1].flag.visiable = true
#	Global.obj.scheme.arr.slot[0][2].flag.visiable = true
#	Global.obj.scheme.arr.slot[0][3].flag.visiable = true
#	Global.obj.scheme.arr.slot[0][4].flag.visiable = true
#	Global.obj.scheme.arr.slot[0][5].flag.visiable = true
#	Global.obj.scheme.arr.slot[0][6].flag.visiable = true
#	Global.obj.scheme.arr.slot[0][7].flag.visiable = true
#	Global.obj.scheme.arr.slot[1][0].flag.visiable = true
#	Global.obj.scheme.arr.slot[1][1].flag.visiable = true
#	Global.obj.scheme.arr.slot[1][2].flag.visiable = true
#	Global.obj.scheme.arr.slot[2][0].flag.visiable = true
#	Global.obj.scheme.arr.slot[2][1].flag.visiable = true
#	Global.obj.scheme.arr.slot[2][2].flag.visiable = true
#	Global.obj.scheme.arr.slot[3][0].flag.visiable = true
#	Global.obj.scheme.arr.slot[3][1].flag.visiable = true
#	Global.obj.scheme.arr.slot[3][2].flag.visiable = true

#	Global.obj.scheme.arr.knot[0][0].flag.visiable = true
#	Global.obj.scheme.arr.knot[0][1].flag.visiable = true
#	Global.obj.scheme.arr.knot[1][0].flag.visiable = true
#	Global.obj.scheme.arr.knot[1][1].flag.visiable = true
#	Global.obj.scheme.arr.knot[2][0].flag.visiable = true
	
	draw_circle(Global.vec.window_size.center, 3, Color(0.0, 0.0, 0.0))
	var x = Global.num.knot.n-1
	var y = x
	Global.obj.scheme.arr.knot[x][y].flag.visiable = true
	
	for slots in Global.obj.scheme.arr.slot:
		for slot in slots:
			if slot.flag.visiable && !slot.flag.blocked:
				draw_polygon(slot.arr.point, PoolColorArray([slot.color.current]))

	for knots in Global.obj.scheme.arr.knot:
		for knot in knots:
			if knot.flag.visiable:
				draw_circle(knot.vec.pos, 3, knot.color.current)

	for edges in Global.obj.scheme.arr.edge:
		for edge in edges:
			if edge.flag.visiable:
				draw_line(edge.arr.point[0], edge.arr.point[1], edge.color.current, 1)
	
	
	

	


