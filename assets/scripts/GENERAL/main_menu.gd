extends Control


@onready var start: Node2D = $start
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
	else:
		start.visible = false
	pass


func _on_play_pressed() -> void:
	button_press_sfx.play()
	get_tree().change_scene_to_file("res://assets/scenes/WORLDS/murder_playground.tscn")
	pass


func _on_exit_pressed() -> void:
	button_press_sfx.play()
	get_tree().quit()
	pass
