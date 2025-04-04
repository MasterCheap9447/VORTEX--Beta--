extends Node3D


@export var SPEED: float = 6.0
@export var DAMAGE: float = 10.0

@onready var check: RayCast3D = $check

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -SPEED)


func _on_life_timeout() -> void:
	queue_free()

func attack() -> void:
	var target = check.get_collider()
	if target != null:
		if target.is_in_group("Player"):
			if target.has_method("damage"):
				target.damage(DAMAGE)
				await get_tree().create_timer(0.01).timeout
				queue_free()
