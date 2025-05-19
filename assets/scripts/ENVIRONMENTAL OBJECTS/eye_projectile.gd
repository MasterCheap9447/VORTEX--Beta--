extends Node3D


@export var VELOCITY : float = 0.2
@export var DAMAGE : float = 1

@onready var damage_area: Area3D = $"damage area"

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	if !global_variables.is_paused:
		position += transform.basis * Vector3(0, 0, -VELOCITY)
		attack()
	pass


func attack() -> void:
	for body in damage_area.get_overlapping_bodies():
		if body.is_in_group("Player"):
			if body.has_method("nrml_damage"):
				body.nrml_damage(DAMAGE)
				queue_free()
	pass


func _on_timer_timeout() -> void:
	queue_free()
	pass
