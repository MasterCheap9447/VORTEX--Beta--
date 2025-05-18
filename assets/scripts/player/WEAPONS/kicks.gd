extends Node3D


@onready var animation: AnimationPlayer = $model/AnimationPlayer
@onready var player: CharacterBody3D = $"../../.."
@onready var direction: Node3D = $"../.."

const PUSH = 18

var is_used : bool

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("kick"):
		if player.is_on_floor():
			is_used = true
			animation.play("normal kick")
		else:
			is_used = true
			player.velocity = direction.transform.basis * Vector3(0,0,PUSH)
			animation.play("drop kick")
	if !animation.is_playing():
		is_used = false
	if !is_used:
		self.position.y = 1000
	else:
		self.position.y = 0
