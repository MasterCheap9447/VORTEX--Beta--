extends Camera3D


@onready var neck: Node3D = $".."
@onready var player: CharacterBody3D = $"../.."
@onready var gun_camera: Camera3D = $"../../UI/viewport_container/viewport/gun_camera"

const SENSITIVITY = 0.002

@export_group("CAMERA VARIABLES")
@export_range(90,140) var FOV: int = 90
@export_range(90,140) var MAX_FOV: int = 120
@export_range(0,50) var FOV_CHANGE: int = 2

const HEADBOB_AMPLITUDE: float = 0.08
const HEADBOB_FREQUENCY: float = 1.5

var headbob_time : float = 0.0


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	
	gun_camera.global_transform = global_transform
	_fov_alter(delta)
	pass



func _unhandled_input(event: InputEvent) -> void:
		## Controling the Camera with the Mouse
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseMotion:
				neck.rotate_y(-event.relative.x * SENSITIVITY)
				rotate_x(-event.relative.y * SENSITIVITY)
				rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _fov_alter(delta):
	var velocity_clamped = clamp(player.velocity.length(), 0.5, 5)
	var target_fov = FOV + FOV_CHANGE * velocity_clamped
	fov = lerp(fov, float(target_fov), delta * 2)
	fov = clamp(fov, FOV, MAX_FOV)
	pass
