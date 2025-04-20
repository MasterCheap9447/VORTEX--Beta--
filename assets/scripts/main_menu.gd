extends Control


@onready var start: Node2D = $start
@onready var play: Node2D = $play
@onready var antarctic_levels: Node2D = $"antarctic levels"
@onready var settings_tab: Control = $"settings tab"

var cur_screen : String


func _ready() -> void:
	cur_screen = "start"
	pass


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		cur_screen = "start"
	
	
	if cur_screen == "start":
		start.visible = true
		play.visible = false
		antarctic_levels.visible = false
		settings_tab.visible = false
	if cur_screen == "continent select":
		start.visible = false
		play.visible = true
		antarctic_levels.visible = false
		settings_tab.visible = false
	if cur_screen == "settings":
		start.visible = false
		play.visible = false
		antarctic_levels.visible = false
		settings_tab.visible = true
	
	
	if cur_screen == "antarctic levels":
		start.visible = false
		play.visible = false
		antarctic_levels.visible = true
	pass


func _on_play_pressed() -> void:
	cur_screen = "continent select"
	pass


func _on_exit_pressed() -> void:
	get_tree().quit()
	pass


func _on_settings_pressed() -> void:
	cur_screen = "settings"
	pass


func _on_antarctica_pressed() -> void:
	cur_screen = "antarctic levels"
	pass


func _on_enter_lvl_1_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/WORLDS/anatarctica/level-1.tscn")
	pass
