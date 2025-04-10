extends Node3D


var equipped: bool

@export var RECOIL: int = 5000

@onready var model: Node3D = $model
@onready var ray: RayCast3D = $ray
@onready var animation: AnimationPlayer = $animation



func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("0"):
		equipped = true
	if Input.is_action_just_pressed("1"):
		equipped = false
	if Input.is_action_just_pressed("2"):
		equipped = false
	
	
	if !animation.is_playing():
	## Alternate Fire
		if Input.is_action_just_pressed("alt shoot"):
			animation.play("shoot")
			alt_fire()
	## Primary Fire
		if Input.is_action_just_pressed("shoot"):
			animation.play("shoot")
	pass


func pime_fire():
	pass

func alt_fire():
	var player = get_parent().get_parent().get_parent().get_parent()
	if ray.is_colliding():
		player.velocity = -player.velocity
