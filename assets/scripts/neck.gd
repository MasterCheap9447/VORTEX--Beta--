extends Node3D


@onready var camera = $camera
@onready var player = $".."
@onready var mine_spawn: Marker3D = $camera/mine_spawn

var mine = load("res://assets/scenes/mine.tscn")
var instance

func _ready():
	pass


func _physics_process(delta):

	if Input.is_action_just_pressed("throwable"):
		if global_variables.is_mine_spawned == false:
			instance = mine.instantiate()
			instance.position = mine_spawn.global_position
			player.get_parent().add_child(instance)
			instance.apply_impulse( (mine_spawn.global_transform.basis * Vector3(0, 0, -1)).normalized() * 10 )
			global_variables.is_mine_spawned = true

		else:
			instance.explode()
			global_variables.is_mine_spawned = false

	pass
