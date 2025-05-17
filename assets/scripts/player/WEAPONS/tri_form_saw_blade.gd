extends CharacterBody3D


@export var SPEED : float = 5
@export var DAMAGE : float = 0.125

@onready var air_res_timer: Timer = $"air resistence timer"
@onready var model: MeshInstance3D = $model
@onready var hit_area: Area3D = $"hit area"

var cant : bool = true

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	model.rotation.x += rad_to_deg(2.5)
	if !is_on_floor():
		velocity.y -= 0.12
	velocity = transform.basis * Vector3(0, 0, -SPEED) * int(cant)
	move_and_slide()
	
	if $"hit area".has_overlapping_areas():
		$sparks.emitting = true
		air_res_timer.start()
	else:
		$sparks.emitting = false
	
	for target in hit_area.get_overlapping_bodies():
		if target.is_in_group("Enemy"):
			if target.has_method("saw_blade_hit"):
				target.saw_blade_hit(DAMAGE)
				velocity = Vector3.ZERO
				cant = false
				air_res_timer.start()
	pass


func _on_air_resistence_timer_timeout() -> void:
	queue_free()
	pass


func _on_destruction_timeout() -> void:
	queue_free()
	pass
