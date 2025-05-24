extends RigidBody3D



@onready var blood_ray: RayCast3D = $"blood stain"
var instance

var blood_stain = load("res://assets/scenes/ENVIRONMENTAL OBJECTS/blood_decal.tscn")

func _ready() -> void:
	randomize()
	apply_impulse(Vector3(randf_range(-10, 10), 10, randf_range(-10, 10)))
	pass


func _process(delta: float) -> void:
	if blood_ray.is_colliding():
		instance = blood_stain.instantiate()
		instance.position = blood_ray.get_collision_point()
		get_parent().add_child(instance)
		get_tree().create_timer(1).timeout
		sleeping = true
	pass
