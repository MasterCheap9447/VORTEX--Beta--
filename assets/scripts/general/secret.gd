extends Node3D


@onready var player_area: Area3D = $"player area"
@onready var cool_s: MeshInstance3D = $"cool S"


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	
	cool_s.rotation.y += deg_to_rad(0.1)
	
	if player_area.has_overlapping_bodies():
		for p in player_area.get_overlapping_bodies():
			if player_area.is_in_group("Player"):
				queue_free()
	pass
