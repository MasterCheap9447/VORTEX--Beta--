extends Node3D


func _ready() -> void:
	position += transform.basis * Vector3(0, 0, -50)


func _on_life_time_timeout() -> void:
	queue_free()
