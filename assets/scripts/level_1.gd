extends Node3D



@export var anchor_animation: AnimationPlayer
@export var grinder_animation: AnimationPlayer
@export var grinder_death_area: Area3D
@export var fan_animation: AnimationPlayer
@export var fan_area: Area3D


func _ready() -> void:
	anchor_animation.play("oscilation")
	grinder_animation.play("grinding")
	fan_animation.play("fan_spin")
	pass


func _process(_delta: float) -> void:
	
	for b in grinder_death_area.get_overlapping_bodies():
		if b.is_in_group("Player"):
			$player.global_position = Vector3(0, 0, 0)

	for b in fan_area.get_overlapping_bodies():
		if b.is_in_group("Player"):
			$player.global_position = Vector3(0, 0, -55)
	
	pass
