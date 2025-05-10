extends Control


@onready var invert_x: CheckButton = $"invert x"
@onready var invert_y: CheckButton = $"invert y"


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	global_variables.invert_x = invert_x.toggle_mode
	global_variables.invert_y = invert_y.toggle_mode
	pass


func _on_invert_x_toggled(toggled_on: bool) -> void:
	!global_variables.invert_x
	pass

func _on_invert_y_toggled(toggled_on: bool) -> void:
	!global_variables.invert_y
	pass
