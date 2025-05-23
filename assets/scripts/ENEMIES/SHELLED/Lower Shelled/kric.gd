extends CharacterBody3D



@export var SPEED: float = 5
@export var HEALTH: float = 1
@export var DAMAGE: float = 1

var player = null
var world = null

@export var player_path := "/root/Endless Mode/player"
@export var world_path := "/root/Endless Mode"

@onready var path_finder: NavigationAgent3D = $"path finder"
@onready var animation: AnimationPlayer = $export/animation
@onready var model: Node3D = $export
@onready var check: RayCast3D = $check

@onready var smoke: GPUParticles3D = $explosion/smoke

@onready var blood_animation: AnimationPlayer = $"Blood Splatter/blood animation"
@onready var explosion_animation: AnimationPlayer = $"explosion/explosion animation"

@onready var explosion_area: Area3D = $"explosion area"
@onready var explosion_collision: CollisionShape3D = $"explosion area/explosion collision"


var ran := RandomNumberGenerator.new()
var dead : bool
var instance
var player_position : Vector3

var status : String = "Normal"
var can_atk : bool = true


func _ready() -> void:
	player = get_node(player_path)
	world = get_node(world_path)
	DAMAGE = 1 * global_variables.difficulty
	HEALTH = 1 * global_variables.difficulty
	SPEED = 5 * global_variables.difficulty
	pass

func _process(_delta: float) -> void:
	
	if status == "shocked":
		animation.play("idle")
	else:
		if velocity.length() > 0:
			animation.play("walk")
	
	if position.x == player.global_position.x:
		if position.z == player.global_position.z:
			animation.play("idle")
	if velocity.length() != 0:
		animation.play("walk")
	else:
		animation.play("idle")
	pass


func _physics_process(_delta: float) -> void:
	if !is_on_floor():
		velocity.y -= 12
	death()
	
	if HEALTH <= 0:
		dead = true
	
	if !model.visible:
		for body in explosion_area.get_overlapping_bodies():
			if body.is_in_group("Xplodable"):
				body.exp_damage(DAMAGE, explosion_area.global_position)
	
	if status == "Shocked":
		animation.play("idle")
	
	if !global_variables.is_paused:
		if !is_on_floor():
			velocity.y -= 12
		if !dead && status != "Shocked":
			velocity = transform.basis * Vector3(0, 12 * int(is_on_floor()), -SPEED)
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			if can_atk:
				if check.is_colliding():
					velocity.y += SPEED
					var target = check.get_collider()
					if target != null:
						if target.is_in_group("Player"):
							explode()
	
		move_and_slide()
	pass

func explode():
	velocity = Vector3.ZERO
	dead = true
	explosion_animation.play("boom")
	model.visible = false
	await get_tree().create_timer(0.9).timeout
	global_position = Vector3(69420, 69420, 69420)
	await get_tree().create_timer(0.1).timeout
	world.add_kill()
	queue_free()
	pass

func death():
	if HEALTH <= 0:
		if can_atk:
			explode()
	pass

func blood_splash():
	blood_animation.play("blood splash")
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
