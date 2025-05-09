extends Node3D

@export var world_size : Vector3 = Vector3(16, 16, 16)
@export_range(-1, 1) var cut_off : float = 0.5

@onready var door: CSGBox3D = $start/door
@onready var enemy_spawn_points: Node3D = $"navigation mesh/enemy spawn points"
@onready var navigation_mesh: NavigationRegion3D = $"navigation mesh"

var wave_no : int
var difficulty : int = global_variables.diff

var data : Array[Vector3] = []
var ran = RandomNumberGenerator.new()
var instance

var kric = load("res://assets/scenes/entities/kric.tscn")
var stalker = load("res://assets/scenes/entities/stalker.tscn")
var gomme = load("res://assets/scenes/entities/gomme.tscn")

func _ready() -> void:
	randomize()
	ran.randomize()
	wave_no = 1
	pass


func _process(delta: float) -> void:
	if global_variables.enemies_alive == 0:
		wave_no += 1
	pass


func _physics_process(delta: float) -> void:
	ran.randi_range(1, 5)
	pass


func _get_random_child(parent_node):
	var random_id  = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)
	pass


func _on_enemy_spawn_time_timeout() -> void:
	var opp_count
	var spawn_point = _get_random_child(enemy_spawn_points).global_position
	opp_count = (difficulty * wave_no) + 2
	if global_variables.enemies_alive <= opp_count:
		instance = kric.instantiate()
		instance.global_position = spawn_point
		navigation_mesh.add_child(instance)
	pass


func _on_enemy_spawn_time_2_timeout() -> void:
	var opp_count
	var spawn_point = _get_random_child(enemy_spawn_points).global_position
	opp_count = (difficulty * wave_no) + 2
	if global_variables.enemies_alive <= opp_count:
		instance = stalker.instantiate()
		instance.global_position = spawn_point
		navigation_mesh.add_child(instance)
	pass


func _on_enemy_spawn_time_3_timeout() -> void:
	var opp_count
	var spawn_point = _get_random_child(enemy_spawn_points).global_position
	opp_count = (difficulty * wave_no) + 2
	if global_variables.enemies_alive <= opp_count:
		instance = gomme.instantiate()
		instance.global_position = spawn_point
		navigation_mesh.add_child(instance)
	pass
