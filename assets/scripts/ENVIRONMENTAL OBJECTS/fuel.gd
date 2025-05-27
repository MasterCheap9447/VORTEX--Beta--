extends RigidBody3D



@export var SPEED : float = 10.0
@export var player_path := "/root/Endless Mode/player"
@onready var stain_ray: RayCast3D = $"stain ray"

var velocity
var player = null
var instance

var oil_stain = load("res://assets/scenes/ENVIRONMENTAL OBJECTS/fuel_decal.tscn")

func _ready() -> void:
	randomize()
	player = get_node(player_path)
	rotation.x = deg_to_rad(randf_range(-1, 1))
	rotation.y = 0
	rotation.z = deg_to_rad(randf_range(-1, 1))
	apply_impulse(transform.basis * Vector3(0, 0, -SPEED))
	look_at(player.global_position)
	pass


func _physics_process(delta: float, ) -> void:
	apply_impulse(transform.basis * Vector3(0, 0, -SPEED))
	pass


func _destroy() -> void:
	if stain_ray.is_colliding():
		instance = oil_stain.instantiate()
		instance.position = stain_ray.get_collision_point()
		instance.rotation.y = randf()
		get_parent().add_child(instance)
		queue_free()
	pass
