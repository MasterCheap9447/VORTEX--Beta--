extends Node3D



@onready var mesh: MeshInstance3D = $mesh
@onready var animation: AnimationPlayer = $animation
@export var delete_mesh: bool


func _on_life_time_timeout() -> void:
	queue_free()

func start(start_pos: Vector3, end_pos:Vector3):
	mesh.scale.x = start_pos.distance_to(end_pos)
	mesh.position.z = -mesh.scale.x / 2
	look_at(end_pos)
	animation.play("default")

func _process(_delta: float) -> void:
	mesh.rotation.z = 0.0
	if delete_mesh == true:
		queue_free()
