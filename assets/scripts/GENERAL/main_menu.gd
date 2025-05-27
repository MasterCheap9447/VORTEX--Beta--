extends Control


@onready var start: Node2D = $start
@onready var settings_tab: Control = $"settings tab"
@onready var difficulty_select: Node2D = $"difficulty select"
@onready var button_press_sfx: AudioStreamPlayer = $"button press SFX"

var cur_screen : String

func _ready() -> void:
	cur_screen = "start"
	pass


func _process(_delta: float) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.is_action_just_pressed("exit"):
		cur_screen = "start"
	
	if cur_screen == "start":
		start.visible = true
		settings_tab.visible = false
		difficulty_select.visible = false
	if cur_screen == "difficulty":
		start.visible = false
		settings_tab.visible = false
		difficulty_select.visible = true
	if cur_screen == "settings":
		start.visible = false
		settings_tab.visible = true
		difficulty_select.visible = false
	
	
	if cur_screen == "antarctic levels":
		start.visible = false
	pass


func _on_play_pressed() -> void:
	button_press_sfx.play()
	cur_screen = "difficulty"
	pass


func _on_exit_pressed() -> void:
	button_press_sfx.play()
	get_tree().quit()
	pass


func _on_settings_pressed() -> void:
	button_press_sfx.play()
	cur_screen = "settings"
	pass


func _on_bomboclat_pressed() -> void:
	global_variables.difficulty = 1
	get_tree().change_scene_to_file("res://assets/scenes/WORLDS/murder_playground.tscn")
	pass


func _on_kys_pressed() -> void:
	global_variables.difficulty = 3
	get_tree().change_scene_to_file("res://assets/scenes/WORLDS/murder_playground.tscn")
	pass
