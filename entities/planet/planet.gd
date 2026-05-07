extends Node2D
class_name Planet


@onready var hull = %Hull
#@onready var horde = %Horde


func _ready():
	var viewport_size = get_viewport_rect().size
	position = viewport_size / 2
	hull.position = -Vector2(Catalog.HULL_CAPSULE_SIZE) * Catalog.CAPSULE_SPRITE_SIZE / 2
	#horde.position = hull.position + Catalog.INSECT_SPRITE_SIZE * 0.5
