extends CharacterBody3D



@export var MAX_SPEED : float = 20
@export var ACCELERATION: float = 1
@export var HEALTH: float = 3
@export var DAMAGE: float = 5

var player = null
var world = null

@export var player_path := "/root/Endless Mode/player"
@export var world_path := "/root/Endless Mode"

@onready var mesh: Node3D = $mesh
@onready var model_animation: AnimationPlayer = $"mesh/model animation"

@onready var checker: RayCast3D = $checker
@onready var navigator: NavigationAgent3D = $navigator

@onready var blood_spawn_point: Node3D = $"blood spawn point"

var ran := RandomNumberGenerator.new()
var dead : bool
var instance
var delt

var status : String = "Normal"
var can_atk : bool = true

var blood = load("res://assets/scenes/ENVIRONMENTAL OBJECTS/blood.tscn")

func _ready() -> void:
	player = get_node(player_path)
	world = get_node(world_path)
	DAMAGE = 5 * global_variables.difficulty
	HEALTH = 3 * global_variables.difficulty
	MAX_SPEED = 20 * global_variables.difficulty
	pass


func _process(_delta: float) -> void:
	death()
	pass


func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y -= 12
	
	velocity = Vector3.ZERO
	
	if !dead:
		if status != "Shocked":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			
			navigator.set_target_position(player.global_position)
			var next_target = navigator.get_next_path_position()
			#velocity = (next_target - global_position).normalized() * move_toward(velocity.length(), MAX_SPEED, ACCELERATION)
			if !model_animation.is_playing():
				model_animation.play("walk")
			
			if checker.is_colliding():
				var pablo = checker.get_collider()
				if pablo.is_in_group("Player"):
					velocity = Vector3.ZERO
					model_animation.play("attack")

	
	move_and_slide()
	pass

func blood_splash():
	for i in range(1, randf_range(10, 14)):
		instance = blood.instantiate()
		instance.position = blood_spawn_point.global_position + Vector3(randf_range(-1,1), randf_range(-1,1), randf_range(-1,1))
		world.add_child(instance)
	pass

func death():
	if HEALTH <= 0:
		dead = true
		await get_tree().create_timer(0.2).timeout
		world.add_kill()
		queue_free()
	pass

func attack(trg):
	trg.nrml_damage(DAMAGE)
	velocity += transform.basis * Vector3(0, 0, MAX_SPEED / 2)
	pass

func tazer_hit(damage,volts) -> void:
	global_variables.STYLE += 10 * global_variables.STYLE_MULTIPLIER
	blood_splash()
	HEALTH -= damage
	status = "Shocked"
	await get_tree().create_timer(volts / 4).timeout
	status = "Normal"
	pass

func di_form_hit(damage, burn) -> void:
	global_variables.STYLE += 10/6 * global_variables.STYLE_MULTIPLIER
	blood_splash()
	HEALTH -= damage/6
	status = "Burned"
	await get_tree().create_timer(3).timeout
	status = "Normal"
	pass

func saw_blade_hit(damage) -> void:
	global_variables.STYLE += 0 * global_variables.STYLE_MULTIPLIER
	blood_splash()
	HEALTH -= damage
	can_atk = false
	await get_tree().create_timer(0.5).timeout
	can_atk = true
	pass

func chainsaw_hit(damage) -> void:
	global_variables.STYLE += 0 * global_variables.STYLE_MULTIPLIER
	blood_splash()
	HEALTH -= damage
	can_atk = false
	await get_tree().create_timer(0.5).timeout
	can_atk = true
	pass

func exp_damage(dmg, pos)  -> void:
	global_variables.STYLE += 20 * global_variables.STYLE_MULTIPLIER
	blood_splash()
	HEALTH -= dmg
	pass
