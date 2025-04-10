extends Node


@onready var player: CharacterBody3D = $"../.."
@onready var neck: Node3D = get_parent().get_parent().get_child(2)

const THRUST_FORCE = 5
const THRUSTER_CONSUMPTION = 4.5
const MAX_THRUST_SPEED = 20

	
var wish_direction: Vector3

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	wish_direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Input.is_action_pressed("thrust"):
		_physics_simulation(delta, wish_direction)
	pass

func _physics_simulation(delta: float, dir: Vector3) -> void:
	player.velocity.y = clamp(player.velocity.y, -9999999999999, MAX_THRUST_SPEED)
	player.velocity.y += THRUST_FORCE
	#FUEL -= THRUSTER_CONSUMPTION
	if dir:
		player.velocity += neck.transform.basis * Vector3(0,0,-MAX_THRUST_SPEED * 10) * delta
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, delta * 12)
		player.velocity.z = move_toward(player.velocity.z, 0.0, delta * 12)
	pass
