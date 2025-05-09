extends Node


var kills: int
var enemies_alive : int = 0
var diff : int = 1

var secrets : int = 0

var PLAYER = preload("res://assets/scenes/entities/player.tscn")

var is_player_sliding: bool

var weapon : int
var weapon_count : int = 2

var is_player_alive : bool = true
var player_spawn_point : Vector3 = Vector3(0,0,0)

### SETTINGS VARIABLES ###
var invert_y : int = -1
var invert_x : int = -1

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("1"):
		weapon = 1
	if Input.is_action_just_pressed("2"):
		weapon = 2
	
	if Input.is_action_pressed("scroll up"):
		weapon += 1
	if Input.is_action_pressed("scroll down"):
		weapon -= 1
	
	if weapon >= 2:
		weapon = 2
	if weapon < 1:
		weapon = 1

func _ready() -> void:
	weapon = 0
