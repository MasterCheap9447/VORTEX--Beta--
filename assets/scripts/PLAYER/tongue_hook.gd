extends Node3D



var can_grapple: bool
var is_grappled: bool
var target_pos: Vector3
var target_pos_gotten: bool

@onready var camera: Camera3D = $".."
@onready var neck: Node3D = $"../.."
@onready var hook_cast: ShapeCast3D = $hook_cast
@onready var player: CharacterBody3D = $"../../.."

@export var NORMAL_FORCE: float = 10.0
@export var RETRACTION_FORCE: float = 8.0

func _ready() -> void:
	pass



func _physics_process(delta: float) -> void:
	
	can_grapple = hook_cast.is_colliding()
	
	if Input.is_action_just_pressed("grapple"):
		if can_grapple:
			if !is_grappled:
				grapple_hook_attach()
	
	pass


func grapple_hook_attach():
	is_grappled = true
	if is_grappled:
		player.velocity.y = 0
		if !target_pos_gotten:
			for i in hook_cast.get_collision_count():
				target_pos = hook_cast.get_collision_point(i) + Vector3(0, 1, 0)
				target_pos_gotten = true
		if target_pos.distance_to(player.global_position) > 1:
			if target_pos_gotten:
				player.position = lerp(player.position, target_pos, 0.05)
		else:
			is_grappled = false
			target_pos_gotten = false
		

func grapple_hook_detach():
	pass
