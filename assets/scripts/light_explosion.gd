extends Node3D


@onready var explode_animation: AnimationPlayer = $explode_animation
@onready var explosion_area: Area3D = $explosion_area


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:

	if explode_animation.is_playing():
		for b in explosion_area.get_overlapping_bodies():
			queue_free()
			if b.is_in_group("entity"):
				b.has_method("explosion_damage")
				b.explosion_damage(0.5, 5.0, global_position)


func explode():
	if !explode_animation.is_playing():
		explode_animation.play("explode")
	await get_tree().create_timer(0.5).timeout
	queue_free()
