extends CanvasLayer



@onready var pause_menu: Control = $"pause menu"
@onready var settings_tab: Control = $"settings tab"
@onready var kill_count: RichTextLabel = $"death screen/kill count"
@onready var death_screen: Control = $"death screen"
@onready var win_screen: Control = $"win screen"
@onready var kills_text: RichTextLabel = $"win screen/kills text"
@onready var fps: RichTextLabel = $fps

func _ready() -> void:
	unpause()
	pass


func _process(delta: float) -> void:
	
	if win_screen.visible == false:
		kills_text.text = str(global_variables.kills)
	fps.text = "FPS: " + str(int(Engine.get_frames_per_second()))
	
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
	get_tree().change_scene_to_file("res://assets/scenes/GENERAL/menu.tscn")
	pass


func _on_settings_pressed() -> void:
	settings_tab.visible = true
	pause_menu.position = Vector2(42069, 42069)
	pass
