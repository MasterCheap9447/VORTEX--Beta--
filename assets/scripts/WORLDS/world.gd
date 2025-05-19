extends Node


signal point11
signal point12

@onready var player: CharacterBody3D = $player
@onready var acid: MeshInstance3D = $acid

@onready var arena_1: CSGCombiner3D = $"NAVREGION/ARENA 1"
@onready var arena_2: CSGCombiner3D = $"NAVREGION/ARENA 2"

# ENEMY SPAWN POINTS
@onready var stalker11_pos: Node3D = $"enemy location/1stalker 1 pos 1"
@onready var stalker12_pos: Node3D = $"enemy location/1stalker 1 pos 2"
@onready var stalker13_pos: Node3D = $"enemy location/1stalker 1 pos 3"
@onready var stalker14_pos: Node3D = $"enemy location/1stalker 1 pos 4"

var enemy_count: int = 0

var instance

var arena11 = load("res://assets/scenes/Maps/1arena1.1.tscn")
var arena12 = load("res://assets/scenes/Maps/1arena1.2.tscn")

## ENEMIES
var stalker = load("res://assets/scenes/entities/stalker.tscn")
@onready var stalker_11: RigidBody3D = $"enemy location/ROOM1/stalker 11"
@onready var stalker_12: RigidBody3D = $"enemy location/ROOM1/stalker 12"
@onready var stalker_13: RigidBody3D = $"enemy location/ROOM1/stalker 13"

@onready var stalker_21: RigidBody3D = $"enemy location/ROOM2/stalker 21"
@onready var stalker_22: RigidBody3D = $"enemy location/ROOM2/stalker 22"
@onready var stalker_23: RigidBody3D = $"enemy location/ROOM2/stalker 23"
@onready var stalker_24: RigidBody3D = $"enemy location/ROOM2/stalker 24"


@onready var door: CSGBox3D = $"NAVREGION/ARENA 1/door"


func _ready() -> void:
	stalker_11.freeze = true
	stalker_12.freeze = true
	stalker_13.freeze = true
	stalker_21.freeze = true
	stalker_22.freeze = true
	stalker_23.freeze = true
	stalker_24.freeze = true



func _physics_process(delta: float) -> void:
	$music.global_position = player.global_position
	
	acid.transform.origin.x = player.global_transform.origin.x
	acid.transform.origin.z = player.global_transform.origin.z
	
	
	## ENEMY SPAWNING
	if player.global_transform.origin.z < 110:
		stalker_11.freeze = false
		stalker_12.freeze = false
		stalker_13.freeze = false
		enemy_count += 1
		
	if player.global_transform.origin.z < 16:
		stalker_21.freeze = false
		stalker_22.freeze = false
		stalker_23.freeze = false
		stalker_24.freeze = false
		enemy_count += 1
	
	if global_variables.kills > 5:
		if player.global_position.y > 3:
			if player.global_position.z < -7.95:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				get_tree().change_scene_to_file("res://assets/scenes/finish_screen.tscn")
	
	if global_variables.kills >= 3:
		door.position = Vector3(100, 100, 100)
