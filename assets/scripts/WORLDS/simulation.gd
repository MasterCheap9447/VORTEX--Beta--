extends Node3D



@onready var enemy_spawn_points: Node3D = $"navigation mesh/enemy spawn points"
@onready var kric_point: Node3D = $"navigation mesh/enemy spawn points/kric point"
@onready var stalker_point: Node3D = $"navigation mesh/enemy spawn points/stalker point"
@onready var gomme_point: Node3D = $"navigation mesh/enemy spawn points/gomme point"
@onready var troll_point: Node3D = $"navigation mesh/enemy spawn points/troll point"
@onready var player: CharacterBody3D = $player

@onready var navigation_mesh: NavigationRegion3D = $"navigation mesh"
@onready var death_area: Area3D = $"death area"


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
var troll = load("res://assets/scenes/ENTITIES/enemies/ORGANIC/Lower Organic/troll.tscn")


func _ready() -> void:
	global_variables.kills = 0
	global_variables.aura_gained = 0.0
	global_variables.time_taken = "00:00:000"
	global_variables.STYLE = 0.0
	ran.randomize()
	randomize()
	await get_tree().create_timer(0.5).timeout
	spawn_enemies = true
	wave_no = 1
	count = 0
	pass


func _process(_delta: float) -> void:
	difficulty = global_variables.difficulty
	global_variables.enemies_alive = count
	
	death_area.position.x = player.global_position.x
	death_area.position.z = player.global_position.z 
	for i in death_area.get_overlapping_bodies():
		if i.is_in_group("Player"):
			player.nrml_damage(999999)
			player.velocity = Vector3.ZERO
	
	## WAVE-LIKE SPAWNING ##
	maximum = ceil(wave_no * difficulty * 1)
	if count <= 2:
		spawn_enemies = true
		wave_no += 1
		global_variables.difficulty += 0.25
	else:
		spawn_enemies = false
	
	if spawn_enemies:
		for i in range(1, maximum):
			spawn_kric()
			spawn_troll()
			spawn_gomme()
			spawn_stalker()
	pass

func wave_spawn(am):
	pass


func _physics_process(_delta: float) -> void:
	ran.randi_range(1, 5)
	pass


func _get_random_child(parent_node):
	var random_id  = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)


func spawn_kric() -> void:
	if !global_variables.is_paused:
		var spawn_point = _get_random_child(kric_point).global_position
		if count < maximum:
			instance = kric.instantiate()
			instance.global_position = spawn_point
			navigation_mesh.add_child(instance)
			count += 1
	pass

func spawn_stalker() -> void:
	if !global_variables.is_paused:
		var spawn_point = _get_random_child(stalker_point).global_position
		if count < maximum:
			instance = stalker.instantiate()
			instance.global_position = spawn_point
			navigation_mesh.add_child(instance)
			count += 1
	pass

func spawn_gomme() -> void:
	if !global_variables.is_paused:
		var spawn_point = _get_random_child(gomme_point).global_position
		if count < maximum:
			instance = gomme.instantiate()
			instance.global_position = spawn_point
			navigation_mesh.add_child(instance)
			count += 1
	pass

func spawn_troll() -> void:
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
