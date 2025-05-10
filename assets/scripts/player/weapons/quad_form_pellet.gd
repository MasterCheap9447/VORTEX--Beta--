extends Node3D


@export var SPEED = 2.0

@onready var half_life: Timer = $"half life"
@onready var explosion_animation: AnimationPlayer = $"explosion/explosion animation"
@onready var explosion_area: Area3D = $"explosion area"
@onready var checker: RayCast3D = $checker

@export var damage: int = 3
@export var burn: int = 5

func _ready() -> void:
	half_life.start()
	pass

func _physics_process(delta: float) -> void:
	
	if checker.is_colliding():
		var target = checker.get_collider()
		explosion_animation.play("boom")
		await get_tree().create_timer(0.3).timeout
		queue_free()
	
	for body in explosion_area.get_overlapping_bodies():
		if body.is_in_group("Xplodable") && !body.is_in_group("Player"):
			if body.has_method("exp_damage"):
				body.exp_damage(damage, explosion_area.global_position)
	
	if !global_variables.is_paused:
		position += transform.basis * Vector3(0, 0, -SPEED)
	pass

func _on_half_life_timeout() -> void:
	explosion_animation.play("boom")
	await get_tree().create_timer(0.3).timeout
	queue_free()
	pass
