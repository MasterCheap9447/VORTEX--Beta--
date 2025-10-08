extends CharacterBody3D


@export_group("Objects")
@export var top_part: Node3D
@export var tail_part: Node3D
@export var tail_guider: RayCast3D
@export var wheel_mesh: Node3D

@export var player: CharacterBody3D



func _physics_process(delta: float) -> void:

	if top_part.global_position.y >= player.global_position.y:
		top_part.look_at(Vector3(player.global_position.x, 1.0, player.global_position.z))
	else:
		top_part.look_at(Vector3(player.global_position.x, player.global_position.y, player.global_position.z))

	var target_rotation = atan2(-velocity.x, -velocity.z)
	rotation.y = lerp_angle(rotation.y, target_rotation, 10.0 * delta)
	wheel_mesh.rotation.x -= deg_to_rad(velocity.length())
