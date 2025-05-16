extends CharacterBody3D


@export var SPEED : float = 5

@onready var air_res_timer: Timer = $"air resistence timer"
@onready var model: MeshInstance3D = $model


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y -= 0.12
	velocity = transform.basis * Vector3(0, 0, -SPEED)
	move_and_slide()
	
	if $"hit area".has_overlapping_areas():
		$sparks.emitting = true
		air_res_timer.start()
	else:
		$sparks.emitting = false
	pass



func _on_air_resistence_timer_timeout() -> void:
	queue_free()
	pass
