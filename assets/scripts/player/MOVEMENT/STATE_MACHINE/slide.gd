extends Node


@onready var player: CharacterBody3D = $"../.."
@onready var neck: Node3D = get_parent().get_parent().get_child(2)
@onready var slide_direction: Node3D = $"../../slide direction"

const SPEED = 24
const JUMP_FORCE = 14
const SLAM_FORCE = 80
const SLAM_CONSUMPTION = 20


var wish_direction: Vector3

func _physics_process(delta: float) -> void:
	print(global_variables.is_player_sliding)
	
	if Input.is_action_pressed("slide"):
		global_variables.is_player_sliding = true
	else:
		global_variables.is_player_sliding  = false
	
	if global_variables.is_player_sliding && player.is_on_floor():
		_physics_simulation()
		player.scale = lerp(player.scale, Vector3(1,0.5,1), delta * 4)
	if !global_variables.is_player_sliding:
		slide_direction.rotation = neck.rotation
		player.scale = lerp(player.scale, Vector3(1,1,1), delta * 4)
		player.velocity.x = move_toward(player.velocity.x, 0, delta * 4)
		player.velocity.z = move_toward(player.velocity.z, 0, delta * 4)
	if Input.is_action_pressed("slide"):
		if !player.is_on_floor():
			player.velocity = Vector3.ZERO
			player.velocity.y = -SLAM_FORCE
		if 	player.is_on_floor():
			player.velocity.y = 0
			#FUEL -= SLAM_CONSUMPTION
	pass


func _physics_simulation() -> void:
	
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	wish_direction = (slide_direction.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if Input.is_action_pressed("slide"):
		player.velocity.x = move_toward(player.velocity.x, wish_direction.x * SPEED, 12)
		player.velocity.z = move_toward(player.velocity.z, wish_direction.z * SPEED, 12)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, 6)
		player.velocity.z = move_toward(player.velocity.z, 0, 6)
