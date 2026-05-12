extends Node2D
class_name Atlas

@export var map_width: int = 192
@export var map_height: int = 108

@export var center_layer: TileMapLayer
@export var ridge_layer: TileMapLayer
@export var sector_layer: TileMapLayer
@export var ore_layer: TileMapLayer

var layers: Array[TileMapLayer] = []
var current_layer_index := 0

var rng := RandomNumberGenerator.new()

func _ready():

	layers = [
		center_layer,
		ridge_layer,
		sector_layer,
		ore_layer
	]

	# передаём atlas в слои один раз
	for l in layers:
		if "atlas" in l:
			l.atlas = self

		l.generate(self)

	current_layer_index = 3
	_update_visibility()


func _process(_delta):

	if Input.is_action_just_pressed("ui_accept"):
		current_layer_index = (current_layer_index + 1) % layers.size()
		_update_visibility()


func _update_visibility():

	for i in range(layers.size()):
		layers[i].visible = (i == current_layer_index)
