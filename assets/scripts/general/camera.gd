extends Camera3D


@export_group("CAMERA VARIABLES")
@export_range(0.0001, 0.001) var SENSITIVITY: float = 0.005
@export_range(90,140) var FOV: int = 100
@export_range(90,140) var MAX_FOV: int = 140
@export_range(0,50) var FOV_CHANGE: int = 7

const HEADBOB_AMPLITUDE: float = 0.08
const HEADBOB_FREQUENCY: float = 1.5

var headbob_time : float = 0.0

@onready var player: CharacterBody3D = $"../.."


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	_headbob_effect(delta)
	_fov_alter(delta)
	pass


### CAMERA ANIMATIONS ###
func _headbob_effect(delta):
	var x = cos(headbob_time * HEADBOB_FREQUENCY/2) * HEADBOB_AMPLITUDE
	var y = sin(headbob_time * HEADBOB_FREQUENCY) * HEADBOB_AMPLITUDE
	headbob_time += delta * player.velocity.length()
	transform.origin = Vector3(x, y, 0)
	pass
func _fov_alter(delta):
	var velocity_clamped = clamp(player.velocity.length(), 0.5, 5)
	var target_fov = FOV + FOV_CHANGE * velocity_clamped
	fov = lerp(fov, float(target_fov), delta)
	fov = clamp(fov, FOV, MAX_FOV)
	pass
