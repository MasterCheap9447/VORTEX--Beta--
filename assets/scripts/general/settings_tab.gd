extends Control


@onready var invert_x: CheckButton = $"invert x"
@onready var invert_y: CheckButton = $"invert y"


func _ready() -> void:
	pass


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass


@warning_ignore("unused_parameter")
func _on_invert_x_toggled(toggled_on: bool) -> void:
	@warning_ignore("standalone_expression")
	-global_variables.invert_x
	pass

@warning_ignore("unused_parameter")
func _on_invert_y_toggled(toggled_on: bool) -> void:
	@warning_ignore("standalone_expression")
	-global_variables.invert_y
	pass
