extends RigidBody3D


@export var VELOCITY = 15.0

@onready var half_life: Timer = $"half life"
@onready var cast: RayCast3D = $cast
@onready var explosion: GPUParticles3D = $explosion

@export var damage: int = 3
@export var burn: int = 5

func _ready() -> void:
	half_life.start()

func _physics_process(delta: float) -> void:
	if cast.is_colliding():
		var target = cast.get_collider()
		if target != null:
			if target.is_in_group("Enemy"):
				if target.has_method("quad_form_hit"):
					target.quad_form_hit(damage, burn)
		
	
	apply_impulse(self.transform.basis * Vector3(0, 0, -VELOCITY))

func _on_half_life_timeout() -> void:
	explosion.emitting = true
	await get_tree().create_timer(0.3).timeout
	queue_free()
