extends Node


@onready var player: CharacterBody3D = $"../.."

const SPEED = 5.0
const JUMP_FORCE = 4.5


func _physics_process(delta: float) -> void:
	_physics_simulation(delta)
	pass

func _physics_simulation(delta) -> void:
	
	player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
	player.velocity.z = move_toward(player.velocity.x, 0, SPEED)
	pass
