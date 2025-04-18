extends Node3D


func _ready() -> void:
	pass


func _on_half_life_timeout() -> void:
	queue_free()
	pass
