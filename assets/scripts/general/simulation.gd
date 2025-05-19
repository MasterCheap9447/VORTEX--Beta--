extends Node3D

@export var world_size : Vector3 = Vector3(16, 16, 16)
@export_range(-1, 1) var cut_off : float = 0.5

@onready var enemy_spawn_points: Node3D = $"navigation mesh/enemy spawn points"
@onready var kric_point: Node3D = $"navigation mesh/enemy spawn points/kric point"
@onready var stalker_point: Node3D = $"navigation mesh/enemy spawn points/stalker point"
@onready var gomme_point: Node3D = $"navigation mesh/enemy spawn points/gomme point"
@onready var navigation_mesh: NavigationRegion3D = $"navigation mesh"

var wave_no : int = 1
var difficulty : int = 1

var data : Array[Vector3] = []
var ran = RandomNumberGenerator.new()
var instance
var count : int = 0
var maximum : int = 5

var kric = load("res://assets/scenes/entities/kric.tscn")
var stalker = load("res://assets/scenes/entities/stalker.tscn")
var gomme = load("res://assets/scenes/entities/gomme.tscn")

func _ready() -> void:
	randomize()
	ran.randomize()
	wave_no = 1
	pass


func _process(_delta: float) -> void:
	if !global_variables.is_paused:
		if global_variables.enemies_alive <= 0:
			wave_no += 1
			count = 0
			maximum = maximum + 5
	pass


func _physics_process(_delta: float) -> void:
	ran.randi_range(1, 5)
	pass


func _get_random_child(parent_node):
	var random_id  = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)


func _on_enemy_spawn_time_timeout() -> void:
	if !global_variables.is_paused:
		var spawn_point = _get_random_child(kric_point).global_position
		if count < maximum:
			instance = kric.instantiate()
			instance.global_position = spawn_point
			navigation_mesh.add_child(instance)
			count += 1
	pass


func _on_enemy_spawn_time_2_timeout() -> void:
	if !global_variables.is_paused:
		var spawn_point = _get_random_child(stalker_point).global_position
		if count < maximum:
			instance = stalker.instantiate()
			instance.global_position = spawn_point
			navigation_mesh.add_child(instance)
			count += 1
	pass


func _on_enemy_spawn_time_3_timeout() -> void:
	if !global_variables.is_paused:
		var spawn_point = _get_random_child(gomme_point).global_position
		if count < maximum:
			instance = gomme.instantiate()
			instance.global_position = spawn_point
			navigation_mesh.add_child(instance)
			count += 1
	pass
