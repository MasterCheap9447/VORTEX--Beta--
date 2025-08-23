extends Node3D


const SPEED = 10
const DAMAGE = 0.25
const TEMPERATURE = 1

@onready var enemy_area: Area3D = $"enemy area"
@onready var animation: AnimationPlayer = $animation
@onready var model: MeshInstance3D = $model

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -SPEED)
	for target in enemy_area.get_overlapping_bodies():
		if target.is_in_group("Enemy"):
			if target.has_method("di_form_hit"):
				target.di_form_hit(DAMAGE, TEMPERATURE)
				model.visible = false
				animation.play("contact_explosion")
				await  get_tree().create_timer(0.2).timeout
				queue_free()
		else:
			model.visible = false
			animation.play("contact_explosion")
			await  get_tree().create_timer(0.2).timeout
			queue_free()
	pass


func detonate() -> void:
	pass


func _on_half_life_timeout() -> void:
	model.visible = false
	animation.play("contact_explosion")
	await  get_tree().create_timer(0.2).timeout
	queue_free()
	pass
