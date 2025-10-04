extends Node3D



@onready var anchor_animation: AnimationPlayer = $level/beautizers/hallway_1/anchors/anchor_animation
@onready var grinder_animation: AnimationPlayer = $level/beautizers/hallway_1/grinder/grinder_animation
@onready var grinder_death_area: Area3D = $level/beautizers/hallway_1/grinder/grinder_death_area
@onready var fan_animation: AnimationPlayer = $level/beautizers/central_room/central_fan/fan_animation
@onready var fan_area: Area3D = $level/beautizers/central_room/central_fan/fan_area


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
