extends CanvasLayer


@onready var pause_menu: Control = $"pause menu"
var is_paused : bool

func _ready() -> void:
	unpause()
	pass


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit") && is_paused == false:
		pause()
	#if Input.is_action_just_pressed("exit") && is_paused == true:
		#unpause()
	pass

func pause() -> void:
	pause_menu.show()
	Engine.time_scale = 0.0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#is_paused = true
	pass

func unpause() -> void:
	pause_menu.hide()
	Engine.time_scale = 1.0
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#is_paused = false
	pass


func _on_resume_pressed() -> void:
	unpause()
	pass


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/menu.tscn")
	pass
