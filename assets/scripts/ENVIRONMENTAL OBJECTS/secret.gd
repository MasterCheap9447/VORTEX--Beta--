extends Node3D


@onready var check: RayCast3D = $check
@onready var player: CharacterBody3D = $"../player"
@onready var explosion: GPUParticles3D = $explosion
@onready var model: MeshInstance3D = $model

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	check.rotation.x += 1
	check.rotation.z += 1
	check.rotation.y += 1
	if check.is_colliding():
		var target = check.get_collider()
		if target.is_in_group("Player"):
			model.hide()
			explosion.emitting = true
			await  get_tree().create_timer(0.5).timeout
			queue_free()
	pass
