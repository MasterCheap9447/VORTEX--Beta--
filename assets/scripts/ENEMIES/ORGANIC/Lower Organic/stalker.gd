extends CharacterBody3D



@export var MAX_SPEED : float = 20
@export var ACCELERATION: float = 5
@export var HEALTH: float = 3
@export var DAMAGE: float = 5

var player = null
var world = null

@export var player_path := "/root/Endless Mode/player"
@export var world_path := "/root/Endless Mode"

@onready var model: Node3D = $model
@onready var check: RayCast3D = $check
@onready var checker: RayCast3D = $checker

@onready var gibbies: GPUParticles3D = $"Blood Splatter/gibbies"
@onready var blood: GPUParticles3D = $"Blood Splatter/blood"
@onready var blood_splash_vfx: GPUParticles3D = $"blood splash VFX"

var ran := RandomNumberGenerator.new()
var dead : bool
var instance
var delt

var status : String = "Normal"
var can_atk : bool = true


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
	
	## GORE SYSTEM ##
	if HEALTH < 3:
		blood_splash_vfx.emitting = true
	
	delt = delta
	if !is_on_floor():
		velocity.y -= 12
	if !global_variables.is_paused:
		if !is_on_floor():
			velocity.y -= 12
		if !dead && status != "Shocked":
			var plr_x = lerp(position.x, player.global_position.x, 0.5)
			var plr_y = global_position.y
			var plr_z = lerp(position.z, player.global_position.z, 0.5) 
			look_at(Vector3(plr_x, plr_y, plr_z), Vector3.UP)
			if is_on_floor():
				velocity = transform.basis * Vector3(0, 0, -move_toward(velocity.length(), MAX_SPEED, ACCELERATION * delta))
			if can_atk:
				if checker.is_colliding():
					var target = checker.get_collider()
					if target != null:
						if target.is_in_group("Player"):
							attack(target)
	if status == "Shocked":
		velocity = Vector3.ZERO
	
	move_and_slide()
	pass

func blood_splash():
	gibbies.emitting = true
	blood.emitting = true
	pass

func death():
	if HEALTH <= 0:
		model.visible = false
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
	global_variables.STYLE += 10 * global_variables.STYLE_MULTIPLIER
	blood_splash()
	HEALTH -= damage
	status = "Burned"
	await get_tree().create_timer(3).timeout
	status = "Normal"
	pass

func saw_blade_hit(damage) -> void:
	global_variables.STYLE += 10 * global_variables.STYLE_MULTIPLIER
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
