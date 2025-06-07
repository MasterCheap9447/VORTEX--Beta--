extends Control


@onready var start: Node2D = $start
@onready var difficulty_select: Node2D = $"difficulty select"
@onready var button_press_sfx: AudioStreamPlayer = $"button press SFX"
@onready var catalogue: Control = $catalogue

@onready var tazer_info: RichTextLabel = $"catalogue/tazer info"
@onready var tri_form_info: RichTextLabel = $"catalogue/tri form info"
 
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
		difficulty_select.visible = false
		catalogue.visible = false
	if cur_screen == "difficulty":
		start.visible = false
		difficulty_select.visible = true
		catalogue.visible = false
	if cur_screen == "settings":
		start.visible = false
		difficulty_select.visible = false
		catalogue.visible = false
	if cur_screen == "catalogue":
		start.visible = false
		difficulty_select.visible = false
		catalogue.visible = true
	pass


func _on_play_pressed() -> void:
	button_press_sfx.play()
	cur_screen = "difficulty"
	pass


func _on_exit_pressed() -> void:
	button_press_sfx.play()
	get_tree().quit()
	pass


func _on_bomboclat_pressed() -> void:
	global_variables.difficulty = 1
	get_tree().change_scene_to_file("res://assets/scenes/WORLDS/murder_playground.tscn")
	pass


func _on_kys_pressed() -> void:
	global_variables.difficulty = 2
	get_tree().change_scene_to_file("res://assets/scenes/WORLDS/murder_playground.tscn")
	pass


func _on_catalogue_pressed() -> void:
	button_press_sfx.play()
	cur_screen = "catalogue"
	pass


func _on_tazer_pressed() -> void:
	tazer_info.show()
	tri_form_info.hide()
	pass


func _on_tri_form_pressed() -> void:
	tazer_info.hide()
	tri_form_info.show()
	pass
