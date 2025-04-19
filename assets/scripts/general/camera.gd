extends Camera3D


@onready var neck: Node3D = get_parent()
@onready var player: CharacterBody3D = $"../.."

const SENSITIVITY = 0.002

@export_group("CAMERA VARIABLES")
@export_range(90,140) var FOV: int = 90
@export_range(90,140) var MAX_FOV: int = FOV + 10
@export_range(0,50) var FOV_CHANGE: int = 7

const HEADBOB_AMPLITUDE: float = 0.08
const HEADBOB_FREQUENCY: float = 1.5

var headbob_time : float = 0.0
var invertiony : int = -1
var invertionx : int = -1


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if player.is_on_floor():
		if !global_variables.is_player_sliding:
			_headbob_effect(delta)
	_fov_alter(delta)
	pass



func _unhandled_input(event: InputEvent) -> void:
	global_variables.invert_x = invertionx
	global_variables.invert_y = invertiony
	
	## Controling the Camera with the Mouse
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(event.relative.x * SENSITIVITY * invertiony)
			self.rotate_x(event.relative.y * SENSITIVITY * invertionx)
			self.rotation.x = clamp(self.rotation.x, deg_to_rad(-80), deg_to_rad(90))
	


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
