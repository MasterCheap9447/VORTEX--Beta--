extends  RigidBody3D



@onready var player_area: Area3D = $"player area"
@export var player_path := "/root/Endless Mode/player"

var player = null


func _ready() -> void:
	randomize()
	player = get_node(player_path)
	rotation.y = rad_to_deg(randf())
	rotation.z = rad_to_deg(randf())
	rotation.x = rad_to_deg(90)
	apply_impulse(transform.basis * Vector3(0, 0, 12))
	pass


func _process(delta: float) -> void:
	for p in player_area.get_overlapping_bodies():
		if p.is_in_group("Player"):
			p.heal(10)
			queue_free()
	pass


func _physics_process(delta: float) -> void:
	pass


func _on_half_life_timeout() -> void:
	queue_free()
	pass
