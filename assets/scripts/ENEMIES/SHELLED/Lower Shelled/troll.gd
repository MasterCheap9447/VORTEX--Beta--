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


var ran := RandomNumberGenerator.new()
var dead : bool

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
	death()
	pass


func _physics_process(delta: float) -> void:
	if !dead:
		if status != "Shocked":
			if checker.is_colliding():
				if !checker.get_collider().is_in_group("Player"):
					velocity.y = SPEED
					player.enable_FUEL()
				else:
					velocity = Vector3.ZERO
					look_at(player.global_position)
					attack()
			else:
				player.enable_FUEL()
				velocity = transform.basis * Vector3(0, 0, -SPEED)
				look_at(player.global_position)
			if !model_animation.is_playing():
				model_animation.play("moving")
		else:
			velocity = Vector3.ZERO
	else:
		rotation.x = 0
		rotation.z = 0
		velocity.x = 0
		velocity.z = 0
		collision_layer = 4
		collision_mask = 4
		if !is_on_floor():
			velocity.y -= 12
		if is_on_floor():
			set_process(false)
			set_physics_process(false)
	
	move_and_slide()
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
	pass

func attack() -> void:
	player.disable_FUEL()


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
