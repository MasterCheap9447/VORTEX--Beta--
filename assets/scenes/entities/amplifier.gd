extends Node3D


var equipped: bool
var momentum : float = 0.0

var recoil : float = 0.0
var damage : float = 0.0

var r_ratio : float = 0.5
var dih_ratio : float = 0.5

@export var DAMGE_MULTIPLIER : int = 3
@export var RECOIL_MULTPLIER : int = 6

@onready var model: Node3D = $model
@onready var hitbox: ShapeCast3D = $hitbox
@onready var animation: AnimationPlayer = $animation
@onready var player: CharacterBody3D = $"../../../.."
@onready var camera: Camera3D = $"../.."


func _process(_delta: float) -> void:
	momentum = player.velocity.length()
	momentum = clamp(momentum, 6.0, 24.0)
	recoil = r_ratio * momentum * RECOIL_MULTPLIER
	damage = dih_ratio * momentum * DAMGE_MULTIPLIER
	
	if Input.is_action_just_pressed("0"):
		equipped = true
	if Input.is_action_just_pressed("1"):
		equipped = false
	if Input.is_action_just_pressed("2"):
		equipped = false
	
	
	if equipped:
		visible = true
		if !animation.is_playing():
	## Alternate Fire
			if Input.is_action_just_pressed("alt shoot"):
				animation.play("shoot")
				alt_fire()
	## Primary Fire
			if Input.is_action_just_pressed("shoot"):
				animation.play("shoot")
				alt_fire()
	else:
		visible = false
				#prime_fire()
	pass


func prime_fire():
	#if ray.is_colliding():
		#player.velocity = -player.velocity
	pass

func alt_fire():
	if hitbox.is_colliding():
		if hitbox.get_collider(0).is_in_group("Enemy"):
			player.velocity.y = recoil 
	pass
