extends Camera2D
class_name AtlasCamera

@export var atlas: Atlas
@export var ship: Ship

@export var follow_speed: float = 12.0
@export var zoom_speed: float = 12.0

var tile_size: Vector2

var zoom_levels: Array[Vector2] = []
var zoom_index := 0
var target_zoom := Vector2.ONE

var target_position := Vector2.ZERO

func _ready():
	await get_tree().process_frame

	tile_size = atlas.center_layer.tile_set.tile_size

	var world_size = Vector2(
		atlas.map_width * tile_size.x,
		atlas.map_height * tile_size.y
	)

	var viewport_size = get_viewport().get_visible_rect().size

	var zoom_full = max(
		viewport_size.x / world_size.x,
		viewport_size.y / world_size.y
	)

	zoom_levels = [
		Vector2(zoom_full, zoom_full),
		Vector2(zoom_full * 2.0, zoom_full * 2.0),
		Vector2(zoom_full * 4.0, zoom_full * 4.0)
	]

	zoom = zoom_levels[0]
	target_zoom = zoom

	position = ship.global_position
	target_position = position

	ship.moved.connect(_on_ship_moved)

func _process(delta):
	handle_zoom_input()
	update_zoom(delta)
	update_follow(delta)
	clamp_to_map()

func _on_ship_moved(_coord: Vector2i, world_pos: Vector2):
	target_position = world_pos

func handle_zoom_input():
	if Input.is_action_just_pressed("ui_page_up"):
		zoom_index -= 1
	elif Input.is_action_just_pressed("ui_page_down"):
		zoom_index += 1

	zoom_index = clamp(zoom_index, 0, zoom_levels.size() - 1)
	target_zoom = zoom_levels[zoom_index]

func update_zoom(delta):
	var t = 1.0 - exp(-zoom_speed * delta)
	zoom = zoom.lerp(target_zoom, t)

func update_follow(delta):
	var t = 1.0 - exp(-follow_speed * delta)
	target_position = ship.global_position
	position = position.lerp(target_position, t)

func clamp_to_map():
	var world_size = Vector2(
		atlas.map_width * tile_size.x,
		atlas.map_height * tile_size.y
	)

	var viewport_size = get_viewport().get_visible_rect().size / zoom
	var half = viewport_size * 0.5

	var min_pos = half
	var max_pos = world_size - half

	if world_size.x <= viewport_size.x:
		position.x = world_size.x * 0.5
	else:
		position.x = clamp(position.x, min_pos.x, max_pos.x)

	if world_size.y <= viewport_size.y:
		position.y = world_size.y * 0.5
	else:
		position.y = clamp(position.y, min_pos.y, max_pos.y)
