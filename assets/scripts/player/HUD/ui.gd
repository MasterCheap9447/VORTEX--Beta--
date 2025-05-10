extends CanvasLayer


@onready var pause_menu: Control = $"pause menu"
@onready var text_edit: TextEdit = $Container/Control/fuel/TextEdit
@onready var settings_tab: Control = $"settings tab"

func _ready() -> void:
	unpause()
	pass


func _process(_delta: float) -> void:
	
	if global_variables.is_player_alive:
		if Input.is_action_just_pressed("exit"):
			pause()
	
	if settings_tab.visible == true && Input.is_action_pressed("exit"):
		settings_tab.visible = false
		pause_menu.position = Vector2(0, 0)
	
	pass

func pause() -> void:
	pause_menu.show()
	Engine.time_scale = 0.0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass

func unpause() -> void:
	pause_menu.hide()
	Engine.time_scale = 1.0
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass


func _on_resume_pressed() -> void:
	unpause()
	pass


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/menu.tscn")
	pass


func _on_settings_pressed() -> void:
	settings_tab.visible = true
	pause_menu.position = Vector2(42069, 42069)
	pass
