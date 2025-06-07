extends Control


@onready var invert_x: CheckButton = $"tab container/GENERAL/container/box/invert x"
@onready var invert_y: CheckButton = $"tab container/GENERAL/container/box/invert y"

@onready var action_list: VBoxContainer = $"tab container/CONTROLS/container/scroller/action list"
var general_button = preload("res://assets/scenes/GENERAL/general_input_mapping.tscn")
var is_remapping : bool = false
var action_to_remap = null
var remapping_button = null
var input_actions = {
	"jump": "Jump",
	"forward": "Move Forwards",
	"backward": "Move Backwards",
	"left": "Move Left",
	"right": "Move Right",
	"shoot": "Primary Fire",
	"alt shoot": "Alternate Fire",
	"weapon type switch": "Weapon Type",
	"kick": "Kick",
	"slide": "Slide / Slam",
	"dash": "Dash",
	"thrust": "Jetpack",
	"1": "First Weapon",
	"2": "Second Weapon"
}


func _ready() -> void:
	global_variables.invert_x = invert_x.button_pressed
	global_variables.invert_y = !invert_y.button_pressed
	
	create_action_list()
	pass


func invert_x_toggled(toggled_on: bool) -> void:
	global_variables.invert_x = !global_variables.invert_x
	pass

func invert_y_toggled(toggled_on: bool) -> void:
	global_variables.invert_y = !global_variables.invert_y
	pass


func create_action_list():
	InputMap.load_from_project_settings()
	for item in action_list.get_children():
		item.queue_free()
	
	for action in input_actions:
		var button = general_button.instantiate()
		var action_label = button.find_child("action")
		var input_label = button.find_child("input")
		
		action_label.text = input_actions[action]
		
		var events  = InputMap.action_get_events(action)
		if  events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
		
		action_list.add_child(button)
		button.pressed.connect(on_input_button_pressed.bind(button, action))
	pass


func on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("input").text = "! Press key to bind !"
	pass


func _input(event):
	if is_remapping: 
		if (
			event is InputEventKey ||
			(event is InputEventMouseButton && event.pressed)
		):
			# Turning Double click to Single click #
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false
			
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			update_action_list(remapping_button, event)
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			accept_event()
	pass


func update_action_list(button, event):
	button.find_child("input").text = event.as_text().trim_suffix(" (Physical)")
	pass


func _on_reset_button_pressed() -> void:
	create_action_list()
	pass
