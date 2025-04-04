extends Control


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("respawn"):
		get_tree().change_scene_to_file("res://assets/scenes/environment.tscn")
	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene_to_file("res://assets/scenes/menu.tscn")
