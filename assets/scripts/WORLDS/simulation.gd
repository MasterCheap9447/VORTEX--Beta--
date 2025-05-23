extends Node3D


@export var world_size : Vector3 = Vector3(16, 16, 16)
@export_range(-1, 1) var cut_off : float = 0.5

@onready var enemy_spawn_points: Node3D = $"navigation mesh/enemy spawn points"
@onready var kric_point: Node3D = $"navigation mesh/enemy spawn points/kric point"
@onready var stalker_point: Node3D = $"navigation mesh/enemy spawn points/stalker point"
@onready var gomme_point: Node3D = $"navigation mesh/enemy spawn points/gomme point"
@onready var troll_point: Node3D = $"navigation mesh/enemy spawn points/troll point"

@onready var navigation_mesh: NavigationRegion3D = $"navigation mesh"

@onready var enemy_spawn_time_1: Timer = $"enemy spawn time 1"
@onready var enemy_spawn_time_2: Timer = $"enemy spawn time 2"
@onready var enemy_spawn_time_3: Timer = $"enemy spawn time 3"
@onready var enemy_spawn_time_4: Timer = $"enemy spawn time 4"


var wave_no : int = 1
var difficulty : int = 1
var spawn_enemies : bool 

var data : Array[Vector3] = []
var ran = RandomNumberGenerator.new()
var instance
var count : int = 0
var maximum : int = 5

var kric = load("res://assets/scenes/ENTITIES/enemies/SHELLED/Lower Shelled/kric.tscn")
var stalker = load("res://assets/scenes/ENTITIES/enemies/ORGANIC/Lower Organic/stalker.tscn")
var gomme = load("res://assets/scenes/ENTITIES/enemies/SHELLED/Lower Shelled/gomme.tscn")
var troll = load("res://assets/scenes/ENTITIES/enemies/SHELLED/Lower Shelled/troll.tscn")

func _ready() -> void:
	randomize()
	ran.randomize()
	wave_no = 1
	spawn_enemies = true
	_on_enemy_spawn_time_timeout()
	_on_enemy_spawn_time_4_timeout()
	pass


func _process(_delta: float) -> void:
	difficulty = global_variables.difficulty
	global_variables.enemies_alive = count
	maximum = 8 * difficulty
	pass


func _physics_process(_delta: float) -> void:
	ran.randi_range(1, 5)
	pass


func _get_random_child(parent_node):
	var random_id  = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)


func kric_spawn():
	if !global_variables.is_paused:
		var spawn_point = _get_random_child(kric_point).global_position
		if count < maximum:
			instance = kric.instantiate()
			instance.global_position = spawn_point
			navigation_mesh.add_child(instance)
			count += 1
	pass
func stalker_spawn():
	if !global_variables.is_paused:
		var spawn_point = _get_random_child(stalker_point).global_position
		if count < maximum:
			instance = stalker.instantiate()
			instance.global_position = spawn_point
			navigation_mesh.add_child(instance)
			count += 1
	pass
func gomme_spawn():
	if !global_variables.is_paused:
		var spawn_point = _get_random_child(gomme_point).global_position
		if count < maximum:
			instance = gomme.instantiate()
			instance.global_position = spawn_point
			navigation_mesh.add_child(instance)
			count += 1
	pass
func troll_spawn():
	if !global_variables.is_paused:
		var spawn_point = _get_random_child(troll_point).global_position
		if count < maximum:
			instance = troll.instantiate()
			instance.global_position = spawn_point
			navigation_mesh.add_child(instance)
			count += 1
	pass


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


func _on_enemy_spawn_time_4_timeout() -> void:
	if !global_variables.is_paused:
		var spawn_point = _get_random_child(troll_point).global_position
		if count < maximum:
			instance = troll.instantiate()
			instance.global_position = spawn_point
			navigation_mesh.add_child(instance)
			count += 1
	pass


func add_kill() -> void:
	count -= 1
	global_variables.kills += 1
	pass
