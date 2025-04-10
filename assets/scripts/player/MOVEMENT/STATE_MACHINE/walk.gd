extends Node


@onready var player: CharacterBody3D = $"../.."
@onready var neck: Node3D = get_parent().get_parent().get_child(2)
@onready var clank: AudioStreamPlayer3D = get_parent().get_child(6)

const SPEED = 8
const JUMP_FORCE = 14
const ACCELERATION = 8

var wish_direction: Vector3

func _physics_process(delta: float) -> void:
	if global_variables.is_player_sliding == false:
		if player.is_on_floor():
			_physics_simulation(delta)
	pass

func _physics_simulation(delta) -> void:
	
	if player.is_on_floor():
		if Input.is_action_just_pressed("jump"):
			player.velocity.y = JUMP_FORCE
	
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	wish_direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if wish_direction:
		player.velocity.x = move_toward(player.velocity.x, wish_direction.x * SPEED, ACCELERATION)
		player.velocity.z = move_toward(player.velocity.z, wish_direction.z * SPEED, ACCELERATION)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
		player.velocity.z = move_toward(player.velocity.z, 0, SPEED)
	
	player.move_and_slide()
	pass
