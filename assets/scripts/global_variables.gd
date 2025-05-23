extends Node


var kills: int
var enemies_alive : int = 0
var difficulty : int = 1

var is_paused : bool

var secrets : int = 0

var PLAYER = load("res://assets/scenes/entities/player.tscn")
var STYLE : float
var STYLE_MULTIPLIER : float = 1.0

var is_player_sliding: bool

var weapon_type : bool = true
var weapon : int
var weapon_count : int = 2

var is_player_alive : bool = true
var player_spawn_point : Vector3 = Vector3(0,0,0)

### SETTINGS VARIABLES ###
var invert_y : bool = false
var invert_x : bool = false



func hit_stop(duration):
	Engine.time_scale = 0
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 0
	pass
