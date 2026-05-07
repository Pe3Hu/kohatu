extends Area2D
class_name Capsule


var hull: Hull
var coord: Vector2i
var token: Token

var status: Bozo.Capsule:
	set(value_):
		status = value_
		%BorderSprite.modulate = Catalog.capsule_to_color[status]

var col: Magistral
var row: Magistral


func setup(hull_: Hull, coord_: Vector2i):
	hull = hull_
	coord = coord_ 
	position = Vector2(coord) * Catalog.CAPSULE_SPRITE_SIZE

func highligh() -> void:
	hull.reset_capsules()
	hull.active_capsule = self
	row.highligh_capsules()
	col.highligh_capsules()
	hull.update_capsules()

func _input_event(_viewport, event_, _shape_idx):
	if event_ is InputEventMouseButton and event_.pressed:
		EventBus.capsule_selected.emit(self)
