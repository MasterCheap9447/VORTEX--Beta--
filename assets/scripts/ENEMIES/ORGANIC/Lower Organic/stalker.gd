extends RigidBody3D



signal add_kill

@export var MAX_SPEED : float = 15
@export var ACCELERATION : float = 1
@export var HEALTH : float = 3
@export var DAMAGE : float = 5

var player = null
var world = null

@export var player_path := "/root/Endless Mode/player"
@export var world_path := "/root/Endless Mode"

@onready var mesh: Node3D = $mesh
@onready var model_animation: AnimationPlayer = $"mesh/model animation"

@onready var checker: RayCast3D = $checker
@onready var navigator: NavigationAgent3D = $navigator
@onready var bite_area: Area3D = $"mesh/model/torso/head/bite area"

@onready var blood_spawn_point: Node3D = $"blood spawn point"
@onready var decay: Timer = $decay

var ran := RandomNumberGenerator.new()
var dead : bool
var instance
var delt
var trigger_once : bool

var status : String = "Normal"
var can_atk : bool = true

var blood = load("res://assets/scenes/ENVIRONMENTAL OBJECTS/blood.tscn")

func _ready() -> void:
	player = get_node(player_path)
	world = get_node(world_path)
	
	DAMAGE = 5 * global_variables.difficulty
	HEALTH = 3 * global_variables.difficulty
	ACCELERATION = 1 * global_variables.difficulty
	
	model_animation.play("spawn")
	pass


func _process(_delta: float) -> void:
	death()
	pass


func _physics_process(delta: float) -> void:
	if !dead:
		sleeping = false
		collision_layer = 1
		collision_mask = 1
		if status != "Shocked":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			
			navigator.set_target_position(player.global_position)
			var next_target = navigator.get_next_path_position()
			apply_impulse((next_target - global_position).normalized() * ACCELERATION)
			if !model_animation.is_playing():
				model_animation.play("walk")
			
			if checker.is_colliding():
				var pablo = checker.get_collider()
				if pablo.is_in_group("Player"):
					model_animation.play("attack")
					attack()
					await get_tree().create_timer(0.6667).timeout
		else:
			sleeping = true
			model_animation.play("shocked")
	pass


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var velocity = state.linear_velocity
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
		state.linear_velocity = velocity
		pass


func blood_splash():
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
			sleeping = true
			collision_layer = 4
			collision_mask = 4
			set_process(false)
			set_physics_process(false)
	pass

func attack():
	if can_atk:
		for trg in bite_area.get_overlapping_bodies():
			if trg.is_in_group("Player"):
				trg.nrml_damage(DAMAGE)
	pass

func tazer_hit(damage,volts) -> void:
	global_variables.STYLE += 10 * global_variables.STYLE_MULTIPLIER
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
	global_variables.STYLE += 10/6 * global_variables.STYLE_MULTIPLIER
	global_variables.aura_gained += 10 * global_variables.STYLE_MULTIPLIER
	blood_splash()
	HEALTH -= damage/6
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
	global_variables.aura_gained += 20 * global_variables.STYLE_MULTIPLIER
	blood_splash()
	HEALTH -= dmg
	pass
