extends StaticBody3D


@onready var check: RayCast3D = $check
@export var player_path : NodePath

var player

func _ready() -> void:
	player = get_node(player_path)

func _process(delta: float) -> void:
	check.look_at(player.global_position)
	if check.is_colliding():
		var target = check.get_collider()
		if target.is_in_group("Player"):
			global_variables.secrets = 1
			queue_free()
