extends Node3D



@export var SPREAD : float = 1
@export var ROTATION : float = 0.5

func _ready() -> void:
	randomize()
	
	position.x += randf_range(-SPREAD, SPREAD)
	position.z += randf_range(-SPREAD, SPREAD)
	rotation.y += randf_range(-ROTATION, ROTATION)
	
	pass
