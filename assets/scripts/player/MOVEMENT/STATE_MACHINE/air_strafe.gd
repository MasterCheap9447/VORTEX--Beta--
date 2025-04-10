extends Node


@export_subgroup("Aerial Movement Variables")
@export_range(0.5,1) var AIR_CAP: float = 0.85
@export_range(750,900) var AIR_ACCELERATION: float = 800.0
@export_range(450,600) var AIR_SPEED: float = 500.0
@export_range(0,5) var THRUST_FORCE: float = 8.0
@export_range(60, 140) var SLAM_FORCE: float = 80.0
@export_range(20,80) var AIR_FRICTION: float = 40.0

@onready var player: CharacterBody3D = $"../.."

var wish_direction: Vector3


func _physics_process(delta: float) -> void:
	if !player.is_on_floor():
		_physics_simulation(delta)
	pass


func _physics_simulation(delta) -> void:
	var cur_speed_in_wish_direction = player.velocity.dot(wish_direction)
	var capped_speed = min((AIR_SPEED*wish_direction).length(), AIR_CAP)
	var add_speed_till_cap = (capped_speed - cur_speed_in_wish_direction)
	if add_speed_till_cap > 0:
		var acceleration_speed = AIR_ACCELERATION * AIR_SPEED * delta
		acceleration_speed = min(acceleration_speed, add_speed_till_cap)
		player.velocity += acceleration_speed * wish_direction 
	pass
	
	var control = max(player.velocity.length(), 14)
	var drop = control * 8 * delta
	var new_speed = max(player.velocity.length() - drop, 0.0)
	if player.velocity.length() > 0:
		new_speed /= player.velocity.length()
	player.velocity *= new_speed
	pass 
