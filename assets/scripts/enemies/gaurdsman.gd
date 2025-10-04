extends CharacterBody3D


@export var top_part: Node3D
@export var tail_part: Node3D

@export var player: CharacterBody3D


func _physics_process(_delta: float) -> void:
	#top_part.look_at(lerp(global_position, Vector3(player.global_position.x, global_position.y, player.global_position.z), delta * 10))
	top_part.look_at(player.global_position + Vector3(0.0, 1.0, 0.0))
