extends Node3D

@export var world_size : Vector3 = Vector3(16, 16, 16)
@export_range(-1, 1) var cut_off : float = 0.5

@onready var door: CSGBox3D = $start/door
@onready var enemy_spawn_points: Node3D = $"navigation mesh/enemy spawn points"
@onready var navigation_mesh: NavigationRegion3D = $"navigation mesh"


var data : Array[Vector3] = []
var wave : int
var enemies_alive : int
var ran = RandomNumberGenerator.new()
var instance

var kric = load("res://assets/scenes/entities/kric.tscn")
var stalker = load("res://assets/scenes/entities/stalker.tscn")
var gomme = load("res://assets/scenes/entities/gomme.tscn")

func _ready() -> void:
	randomize()
	ran.randomize()
	wave = 0
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	ran.randi_range(1, 5)
	pass


func _get_random_child(parent_node):
	var random_id  = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)
	pass


func _on_enemy_spawn_time_timeout() -> void:
	var rng
	rng = ran.randi_range(0, 8)
	if rng > 0 && rng < 4:
		var spawn_point = _get_random_child(enemy_spawn_points).global_position
		instance = kric.instantiate()
		instance.position = spawn_point
		navigation_mesh.add_child(instance)
	if rng <= 4 && rng >= 8:
		var spawn_point = _get_random_child(enemy_spawn_points).global_position
		instance = stalker.instantiate()
		instance.position = spawn_point
		navigation_mesh.add_child(instance)
	if rng == 8:
		var spawn_point = _get_random_child(enemy_spawn_points).global_position
		instance = gomme.instantiate()
		instance.position = spawn_point
		navigation_mesh.add_child(instance)
	await get_tree().create_timer(1).timeout
	pass
