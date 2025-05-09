extends CharacterBody3D



@onready var ring_1: MeshInstance3D = $"model/ring 1"
@onready var ring_2: MeshInstance3D = $"model/ring 2"
@onready var ring_3: MeshInstance3D = $"model/ring 3"
@onready var player: CharacterBody3D = $"../player"
@onready var eye_holder: Node3D = $eye_holder
@onready var eye: MeshInstance3D = $eye_holder/eye

var eyes = load("res://assets/scenes/projectiles/eye.tscn")

var instance
var ran = RandomNumberGenerator.new()


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	# ring rotations
	ring_1.rotation.x += 2.5 * delta
	ring_2.rotation.z += 3.5 * delta
	ring_3.rotation.y += 5.0 * delta
	# look at player
	eye_holder.look_at(Vector3(player.global_position.x, player.global_position.y, player.global_position.z))
	# shooting
	instance = eyes.instantiate()
	instance.position = eye.global_position
	instance.transform.basis = eye_holder.global_transform.basis
	get_parent().add_child(instance)
