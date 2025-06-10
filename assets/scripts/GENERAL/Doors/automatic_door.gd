extends Node3D



var openable : bool = true

var Uonce : bool
var Donce : bool

var player = null
@export var player_path = "/root/World/player"

@onready var player_check_area: Area3D = $"model/player check area"
@onready var door: Node3D = $model
@onready var animation: AnimationPlayer = $animation


func _ready() -> void:
	player = get_node(player_path)
	animation.play("downhold")
	pass



func _process(delta: float) -> void:
	
	if openable:
		for i in player_check_area.get_overlapping_bodies():
			if i.is_in_group("Player"):
				if !animation.is_playing():
					animation.play("upward")
				animation.play("uphold")
			else:
				openable = false
	else:
		if !animation.is_playing():
			animation.play("downward")
		animation.play("downhold")
	
	pass
