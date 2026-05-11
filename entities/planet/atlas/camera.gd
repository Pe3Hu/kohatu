extends Camera2D
class_name AtlasCamera


@export var atlas: Atlas

@export var speed: float = 3600.0

@export var zoom_step: float = 0.025
@export var min_zoom: float = 0.25   # далеко (стратегический вид)
@export var max_zoom: float = 1.0     # близко

var target_zoom: Vector2


# =========================
# 🚀 INIT
# =========================

func _ready():
	await get_tree().process_frame
	
	min_zoom = calculate_min_zoom()
	
	zoom = Vector2(min_zoom, min_zoom)
	target_zoom = zoom
	
	position = get_map_center()
	clamp_to_map()

func calculate_min_zoom() -> float:
	var world_size = Vector2(
		atlas.map_width * atlas.tile_size,
		atlas.map_height * atlas.tile_size
	)
	
	var viewport_size = get_viewport_rect().size
	
	var zoom_x = viewport_size.x / world_size.x
	var zoom_y = viewport_size.y / world_size.y
	
	# берём МИНИМАЛЬНЫЙ, чтобы всё влезло
	return min(zoom_x, zoom_y)

# =========================
# 🎮 INPUT
# =========================

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		
		var mouse_before = get_global_mouse_position()
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom += Vector2(zoom_step, zoom_step)
		
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom -= Vector2(zoom_step, zoom_step)
		
		target_zoom.x = clamp(target_zoom.x, min_zoom, max_zoom)
		target_zoom.y = clamp(target_zoom.y, min_zoom, max_zoom)
		
		var mouse_after = get_global_mouse_position()
		position += mouse_before - mouse_after


# =========================
# 🔄 PROCESS
# =========================

func _process(delta):
	handle_movement(delta)
	smooth_zoom()
	clamp_to_map()
	position = position.round()


# =========================
# 🧭 MOVEMENT
# =========================

func handle_movement(delta):
	var dir = Vector2.ZERO
	
	if Input.is_key_pressed(KEY_W):
		dir.y -= 1
	if Input.is_key_pressed(KEY_S):
		dir.y += 1
	if Input.is_key_pressed(KEY_A):
		dir.x -= 1
	if Input.is_key_pressed(KEY_D):
		dir.x += 1
	
	dir = dir.normalized()
	position += dir * speed * delta / zoom.x  # 🔥 важно: скорость зависит от zoom


# =========================
# 🔍 ZOOM
# =========================

func smooth_zoom():
	zoom = zoom.lerp(target_zoom, 0.15)


# =========================
# 🧱 CLAMP (ИСПРАВЛЕНО)
# =========================

func clamp_to_map():
	var world_size = Vector2(
		atlas.map_width * atlas.tile_size,
		atlas.map_height * atlas.tile_size
	)

	var viewport_size = get_viewport_rect().size / zoom
	var half_view = viewport_size * 0.5

	var min_pos = half_view
	var max_pos = world_size - half_view

	# 🔥 защита от маленьких карт / зума
	if max_pos.x < min_pos.x:
		position.x = world_size.x * 0.5
	else:
		position.x = clamp(position.x, min_pos.x, max_pos.x)

	if max_pos.y < min_pos.y:
		position.y = world_size.y * 0.5
	else:
		position.y = clamp(position.y, min_pos.y, max_pos.y)
# =========================
# 🎯 CENTER
# =========================

func get_map_center():
	return Vector2(
		atlas.map_width * atlas.tile_size * 0.5,
		atlas.map_height * atlas.tile_size * 0.5
	)
