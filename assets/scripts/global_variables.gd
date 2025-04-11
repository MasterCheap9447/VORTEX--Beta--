extends Node


var room_num: int = 0

var kills: int = 0

var secrets : int = 0

var PLAYER = preload("res://assets/scenes/entities/player.tscn")

var is_player_sliding: bool

var weapon : int

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("0"):
		weapon = 0
	if Input.is_action_just_pressed("1"):
		weapon = 1
	if Input.is_action_just_pressed("2"):
		weapon = 2

func _ready() -> void:
	weapon = 0
