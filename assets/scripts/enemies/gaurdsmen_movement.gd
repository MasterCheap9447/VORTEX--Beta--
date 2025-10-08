extends Node3D


var player: CharacterBody3D

@export var self_prime: CharacterBody3D
@export var navigator: NavigationAgent3D

@export_range(4, 8) var SPEED: int = 6


func _ready() -> void:
	player = self_prime.player


func _physics_process(delta: float) -> void:
	update_path(delta)
	self_prime.move_and_slide()


func update_path(delta):
	navigator.set_target_position(player.global_position)
	var next_navigation_point = navigator.get_next_path_position()
	self_prime.velocity = lerp(self_prime.velocity, ( next_navigation_point - self_prime.global_position ).normalized() * SPEED, delta * 10)
