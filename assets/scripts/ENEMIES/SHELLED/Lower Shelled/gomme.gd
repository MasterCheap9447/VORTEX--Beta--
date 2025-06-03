extends StaticBody3D



@export var SPEED: float = 5
@export var HEALTH: float = 5
@export var DAMAGE: float = 2

var player = null
var world = null

@export var player_path := "/root/Endless Mode/player"
@export var world_path := "/root/Endless Mode"

@onready var mesh: Node3D = $mesh
@onready var model_animation: AnimationPlayer = $"mesh/model animation"
@onready var check: RayCast3D = $check
@onready var collectable_spawn: Node3D = $"collectable spawn"
@onready var cooldown: Timer = $cooldown

@onready var blood_animation: AnimationPlayer = $"blood splash/blood_animation"
@onready var blood_decals: Node3D = $"blood splash/blood decals"

var blood_stain = preload("res://assets/scenes/ENVIRONMENTAL OBJECTS/blood_stain.tscn")
var eye = load("res://assets/scenes/projectiles/eye.tscn")

var ran := RandomNumberGenerator.new()
var dead : bool
var instance

var status : String = "Normal"
var can_atk : bool = true


func _ready() -> void:
	world = get_node(world_path)
	player = get_node(player_path)
	
	DAMAGE = 2 * global_variables.difficulty
	HEALTH = 5 * global_variables.difficulty
	SPEED = 5 * global_variables.difficulty
	cooldown.wait_time = 1 * global_variables.difficulty
	
	model_animation.play("spawn")
	pass


func _process(delta: float) -> void:
	death()
	pass


func _physics_process(delta: float) -> void:
	
	if !dead:
		if status != "Shocked":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			attack()
		else:
			model_animation.play("shocked")
	pass

func death():
	if HEALTH <= 0:
		var ran = randi_range(1,2)
		if dead == false:
			if ran == 1:
				model_animation.play("death 1")
			if ran == 2:
				model_animation.play("death 2")
			world.add_kill()
			dead = true
			set_process(false)
			set_physics_process(false)
	pass

func blood_splash():
	blood_animation.play("splash")
	await get_tree().create_timer(1).timeout
	for b in blood_decals.get_children():
		instance = blood_stain.instantiate()
		instance.position = b.global_position
		instance.rotation = b.global_rotation
		world.add_child(instance)
	pass

func attack() -> void:
	if check.is_colliding():
		var target = check.get_collider()
		if target != null:
			if target.is_in_group("Player"):
				if !model_animation.is_playing():
					model_animation.play("attack")
					instance = eye.instantiate()
					instance.position = check.global_position
					instance.transform.basis = check.global_transform.basis
					get_parent().add_child(instance)
	pass

func slam_damage(damage):
	HEALTH -= damage
	pass

func kick_hit(damage) -> void:
	HEALTH -= damage
	pass

func tazer_hit(damage,volts) -> void:
	global_variables.STYLE += 10
	global_variables.aura_gained += 10 * global_variables.STYLE_MULTIPLIER
	blood_splash()
	HEALTH -= damage
	status = "Shocked"
	await get_tree().create_timer(volts / 4).timeout
	status = "Normal"
	pass

func tazer_pierce_hit(damage,volts) -> void:
	global_variables.STYLE += 10 * global_variables.STYLE_MULTIPLIER
	global_variables.aura_gained += 10 * global_variables.STYLE_MULTIPLIER
	blood_splash()
	HEALTH -= damage
	status = "Shocked"
	volts = clamp(volts, 3/4, 5.0)
	await get_tree().create_timer(volts).timeout
	status = "Normal"
	pass

func di_form_hit(damage, burn) -> void:
	global_variables.STYLE += 10 * global_variables.STYLE_MULTIPLIER
	global_variables.aura_gained += 10 * global_variables.STYLE_MULTIPLIER
	blood_splash()
	HEALTH -= damage
	status = "Burned"
	await get_tree().create_timer(3).timeout
	status = "Normal"
	pass

func saw_blade_hit(damage) -> void:
	blood_splash()
	HEALTH -= damage
	can_atk = false
	await get_tree().create_timer(0.5).timeout
	can_atk = true
	pass

func chainsaw_hit(damage) -> void:
	blood_splash()
	HEALTH -= damage
	can_atk = false
	await get_tree().create_timer(0.5).timeout
	can_atk = true
	pass

func exp_damage(dmg, pos)  -> void:
	global_variables.STYLE += 20 * global_variables.STYLE_MULTIPLIER
	global_variables.aura_gained += 10 * global_variables.STYLE_MULTIPLIER
	blood_splash()
	HEALTH -= dmg
	pass


func _on_cooldown_timeout() -> void:
	if !dead && status != "Shocked":
		if can_atk:
			attack()
	pass



func isnt_on_screen() -> void:
	model_animation.stop()
	if !dead:
		position += transform.basis * Vector3(0, 0, -1)
	pass
