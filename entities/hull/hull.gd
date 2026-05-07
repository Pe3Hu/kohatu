extends Node2D
class_name Hull


@export var capsule_scene: PackedScene
@export var magistral_scene: PackedScene

@export var capsules: Node2D
@export var magistrals: Node2D

var vector_to_capsule: Dictionary
var vector_to_magistral: Dictionary

var active_capsule: Capsule


func _ready():
	EventBus.capsule_selected.connect(_on_capsule_selected)
	init_capsules()

func init_capsules() -> void:
	init_magistrals()
	
	for _y in Catalog.HULL_CAPSULE_SIZE.y:
		for _x in Catalog.HULL_CAPSULE_SIZE.x:
			var coord = Vector2i(_x, _y)
			add_capsule(coord)

func init_magistrals() -> void:
	for _y in Catalog.HULL_CAPSULE_SIZE.y:
		var coord = Vector2i(0, _y + 1)
		add_magistral(coord, Bozo.Magistral.ROW)
	
	for _x in Catalog.HULL_CAPSULE_SIZE.x:
		var coord = Vector2i(_x + 1, 0)
		add_magistral(coord, Bozo.Magistral.COL)

func add_magistral(coord_: Vector2i, type_: Bozo.Magistral) -> void:
	var magistral = magistral_scene.instantiate()
	magistral.setup(self, coord_, type_)
	magistrals.add_child(magistral)
	vector_to_magistral[coord_] = magistral

func add_capsule(coord_: Vector2i) -> void:
	var capsule = capsule_scene.instantiate()
	capsule.setup(self, coord_)
	capsules.add_child(capsule)
	
	var row_coord = Vector2i(0, coord_.y + 1)
	var row_magistral = vector_to_magistral[row_coord]
	row_magistral.capsules.append(capsule)
	capsule.row = row_magistral
	
	var col_coord = Vector2i(coord_.x + 1, 0)
	var col_magistral = vector_to_magistral[col_coord]
	col_magistral.capsules.append(capsule)
	capsule.col = col_magistral

func _on_capsule_selected(capsule_: Capsule):
	active_capsule = capsule_
	active_capsule.highligh()

func reset_capsules() -> void:
	for capsule in capsules.get_children():
		capsule.status = Bozo.Capsule.NONE

func update_capsules() -> void:
	var col_index = active_capsule.coord.x
	
	for capsule in capsules.get_children():
		if capsule.status != Bozo.Capsule.MIDDLE:
			if capsule.coord.x < col_index:
				capsule.status = Bozo.Capsule.LEFT
			
			if capsule.coord.x > col_index:
				capsule.status = Bozo.Capsule.RIGHT
