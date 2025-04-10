extends Node


@onready var player: CharacterBody3D = $"../.."
@onready var neck: Node3D = get_parent().get_parent().get_child(2)

var DASH_FORCE = 75.0
const DASH_CONSUMPTION = 4.5

var is_dashing: bool
var wish_direction: Vector3

func _physics_process(delta: float) -> void:
	
	if player.is_on_floor():
		DASH_FORCE = 75.0
	else:
		DASH_FORCE = 30
	
	if !player.is_on_floor():
		_physics_simulation(delta)
	pass

func _physics_simulation(delta) -> void:
	
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	wish_direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Input.is_action_just_pressed("dash"):
		if wish_direction:
			is_dashing = true
			await get_tree().create_timer(0.05).timeout
			is_dashing = false
		if !wish_direction:
			is_dashing = true
			await get_tree().create_timer(0.05).timeout
			is_dashing = false
	
	if is_dashing:
		player.velocity.y = 0
		if wish_direction:
			player.velocity = wish_direction * DASH_FORCE
		if !wish_direction:
			player.velocity = neck.transform.basis * Vector3(0,0,-DASH_FORCE)
	pass
