extends Node2D


func _draw():
	for points in Global.arr.grid:
		for point in points:
			draw_circle(point, 3, Color(1.0, 1.0, 1.0))
	
	var color = Color(1.0, 0.0, 0.0)
	var vector = Vector2(0,0)
	draw_polygon(get_points_by_vector(vector), PoolColorArray([color]))

func get_points_by_index(triangle_index_):
	var m = Global.num.grid.n
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
		a = Vector2(x+1,y)
		b = Vector2(x,y)
		c = Vector2(x+1,y+1)
		
		if triangle_index_ % 2 == 1:
			a.x -= 1
			a.y += 1
		
	var vecs = [a,b,c]
	var points = []
	
	for vec in vecs:
		points.append(Global.arr.grid[vec.x][vec.y])
		
	return points

func get_points_by_vector(triangle_vector_):
	var m = Global.num.grid.n*2
	var index = int(triangle_vector_.y*m + triangle_vector_.x)
	return get_points_by_index(index)
