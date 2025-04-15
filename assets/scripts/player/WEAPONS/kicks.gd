extends Node3D


@onready var animation: AnimationPlayer = $model/AnimationPlayer
@onready var player: CharacterBody3D = $"../../../.."
@onready var direction: Node3D = get_parent().get_parent().get_parent()

const PUSH = 18

var is_used : bool

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("kick"):
		player.velocity = direction.transform.basis * Vector3(0,0,PUSH)
		if player.is_on_floor():
			is_used = true
			if !animation.is_playing():
				animation.play("normal kick")
		else:
			is_used = true
			if !animation.is_playing():
				animation.play("drop kick")
	if Input.is_action_just_released("kick"):
		is_used = false
	if is_used:
		visible = true
	else:
		visible = false
