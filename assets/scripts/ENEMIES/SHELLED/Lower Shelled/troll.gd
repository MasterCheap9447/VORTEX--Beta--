extends CharacterBody3D


@export var SPEED : float = 10
@export var HEALTH: float = 1
@export var DAMAGE: float = 5

var player = null
var world = null

@export var player_path := "/root/Endless Mode/player"
@export var world_path := "/root/Endless Mode"

@onready var mesh: Node3D = $mesh
@onready var checker: RayCast3D = $checker
@onready var model_animation: AnimationPlayer = $"mesh/model animation"
@onready var collectable_spawn: Node3D = $"collectable spawn"
@onready var ray: RayCast3D = $ray

@onready var blood_animation: AnimationPlayer = $"blood splash/blood_animation"
@onready var blood_decals: Node3D = $"blood splash/blood decals"

var blood_stain = preload("res://assets/scenes/ENVIRONMENTAL OBJECTS/blood_stain.tscn")

var ran := RandomNumberGenerator.new()
var dead : bool
var instance

var status : String = "Normal"
var can_atk : bool = true


func _ready() -> void:
	player = get_node(player_path)
	world = get_node(world_path)
	
	DAMAGE = 1 * global_variables.difficulty
	HEALTH = 1 * global_variables.difficulty
	SPEED = 10 * global_variables.difficulty
	
	pass


func _process(_delta: float) -> void:
	ray.look_at(player.global_position)
	death()
	pass


func _physics_process(delta: float) -> void:
	if !dead:
		if status != "Shocked":
			attack()
			if checker.is_colliding():
				if checker.get_collider().is_in_group("Player"):
					velocity = lerp(velocity, Vector3.ZERO, delta * 10)
					look_at(player.global_position)
				else:
					velocity.y = SPEED
					player.enable_FUEL()
			else:
				player.enable_FUEL()
				velocity = lerp(velocity, transform.basis * Vector3(0, 0, -SPEED), delta * 10)
				look_at(player.global_position)
			if !model_animation.is_playing():
				model_animation.play("moving")
		else:
			velocity = Vector3.ZERO
			model_animation.play("shocked")
	else:
		collision_layer = 1
		collision_mask = 12
		rotation.x = 0
		rotation.z = 0
		velocity.x = 0
		velocity.z = 0
		player.enable_FUEL()
		if !is_on_floor():
			velocity.y -= 12
		if is_on_floor():
			set_process(false)
			set_physics_process(false)
	
	move_and_slide()
	pass

func blood_splash():
	blood_animation.play("splash")
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
	pass

func attack() -> void:
	if ray.is_colliding():
		var target = ray.get_collider()
		if target.is_in_group("Player"):
			player.disable_FUEL()
	pass

func slam_damage(damage):
	HEALTH -= damage
	velocity = abs(player.global_position - position) * damage
	pass

func kick_hit(damage) -> void:
	HEALTH -= damage
	pass

func tazer_hit(damage,volts) -> void:
	global_variables.STYLE += 10
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

func equilizer_hit(damge) -> void:
	global_variables.STYLE += 1
	global_variables.aura_gained += 1 * global_variables.STYLE_MULTIPLIER
	blood_splash()
	HEALTH -= damge
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
	global_variables.aura_gained += 20 * global_variables.STYLE_MULTIPLIER
	blood_splash()
	HEALTH -= dmg
	pass
