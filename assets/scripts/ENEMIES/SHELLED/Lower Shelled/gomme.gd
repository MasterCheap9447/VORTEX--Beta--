extends CharacterBody3D



@export var SPEED: float = 5
@export var HEALTH: float = 5
@export var DAMAGE: float = 2

var player = null
var world = null

@export var player_path := "/root/Endless Mode/player"
@export var world_path := "/root/Endless Mode"

@onready var model: Node3D = $model
@onready var check: RayCast3D = $check

@onready var blood_animation: AnimationPlayer = $"Blood Splatter/blood animation"

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
	pass


func _physics_process(delta: float) -> void:
	death()
	
	if HEALTH <= 0:
		dead = true
	
	if !global_variables.is_paused:
		if !is_on_floor():
			velocity.y -= 12
		if !dead && status != "Shocked":
			check.look_at(Vector3(player.global_position.x, player.global_position.y + 1, player.global_position.z), Vector3.UP)
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	move_and_slide()
	pass

func death():
	if HEALTH <= 0:
		model.visible = false
		dead = true
		await get_tree().create_timer(0.2).timeout
		world.add_kill()
		queue_free()
	pass

func blood_splash():
	blood_animation.play("blood splash")
	pass

func attack() -> void:
	if check.is_colliding():
		var target = check.get_collider()
		if target != null:
			if target.is_in_group("Player"):
				instance = eye.instantiate()
				instance.position = check.global_position
				instance.transform.basis = check.global_transform.basis
				get_parent().add_child(instance)
	pass

func tazer_hit(damage,volts) -> void:
	global_variables.STYLE += 10
	blood_splash()
	HEALTH -= damage
	status = "Shocked"
	await get_tree().create_timer(volts / 4).timeout
	status = "Normal"
	pass

func di_form_hit(damage, burn) -> void:
	global_variables.STYLE += 10
	blood_splash()
	HEALTH -= damage
	status = "Burned"
	await get_tree().create_timer(3).timeout
	status = "Normal"
	pass

func saw_blade_hit(damage) -> void:
	global_variables.STYLE += 10
	blood_splash()
	HEALTH -= damage
	can_atk = false
	await get_tree().create_timer(0.5).timeout
	can_atk = true
	pass

func chainsaw_hit(damage) -> void:
	global_variables.STYLE += 0
	blood_splash()
	HEALTH -= damage
	can_atk = false
	await get_tree().create_timer(0.5).timeout
	can_atk = true
	pass

func exp_damage(dmg, pos)  -> void:
	global_variables.STYLE += 20
	blood_splash()
	HEALTH -= dmg
	pass


func _on_cooldown_timeout() -> void:
	if !dead && status != "Shocked":
		if can_atk:
			attack()
	pass
