extends Control


@onready var main: CanvasLayer = get_parent()

func _ready() -> void:
	main.pause()
	pass


func _process(delta: float) -> void:
	pass


func _on_resume_pressed() -> void:
	
	pass

func showed():
	visible = true
	pass
