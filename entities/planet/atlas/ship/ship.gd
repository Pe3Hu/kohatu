extends Node2D
class_name Ship

signal moved(coord: Vector2i, world_pos: Vector2)

@export var atlas: Atlas
@export var move_cooldown: float = 0.12

var coord: Vector2i
var _timer := 0.0

func _ready():
	coord = Vector2i(atlas.map_width / 2, atlas.map_height / 2)
	_update()

func _process(delta):
	_timer += delta
	if _timer < move_cooldown:
		return

	var dir := Vector2i.ZERO

	if Input.is_key_pressed(KEY_W):
		dir.y -= 1
	elif Input.is_key_pressed(KEY_S):
		dir.y += 1
	elif Input.is_key_pressed(KEY_A):
		dir.x -= 1
	elif Input.is_key_pressed(KEY_D):
		dir.x += 1

	if dir == Vector2i.ZERO:
		return

	var next = coord + dir

	if next.x < 0 or next.y < 0 or next.x >= atlas.map_width or next.y >= atlas.map_height:
		return

	coord = next
	_update()
	_timer = 0.0

func _update():
	var tile_size = atlas.center_layer.tile_set.tile_size

	var world_pos = Vector2(
		(coord.x + 0.5) * tile_size.x,
		(coord.y + 0.5) * tile_size.y
	)

	global_position = world_pos
	moved.emit(coord, world_pos)
