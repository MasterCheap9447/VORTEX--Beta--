extends CharacterBody3D


@export var SPEED : float = 10
@export var HEALTH: float = 1
@export var DAMAGE: float = 5

var player = null

@export var player_path := "/root/Endless Mode/player"

@onready var model: Node3D = $model
@onready var check: RayCast3D = $check
@onready var checker: RayCast3D = $checker

@onready var gibbies: GPUParticles3D = $"Blood Splatter/gibbies"
@onready var blood: GPUParticles3D = $"Blood Splatter/blood"
@onready var explosion_animation: AnimationPlayer = $"explosion/explosion animation"
@onready var explosion_area: Area3D = $"explosion area"

var ran := RandomNumberGenerator.new()
var dead : bool
var instance
var delt

var status : String = "Normal"
var can_atk : bool = true


func _ready() -> void:
	player = get_node(player_path)
	look_at(Vector3(player.global_position.x, player.global_position.y, player.global_position.z), Vector3.UP)
	global_variables.enemies_alive += 1
	pass


func _process(_delta: float) -> void:
	death()
	pass


func _physics_process(delta: float) -> void:
	delt = delta
	
	if !model.visible:
		for body in explosion_area.get_overlapping_bodies():
			if body.is_in_group("Xplodable"):
				body.exp_damage(DAMAGE, explosion_area.global_position)
	
	if !global_variables.is_paused:
		if !dead && status != "Shocked":
			var plr_x = lerp(position.x, player.global_position.x, 0.5)
			var plr_y = lerp(position.y, player.global_position.y, 0.5)
			var plr_z = lerp(position.z, player.global_position.z, 0.5)
			look_at(Vector3(plr_x, plr_y, plr_z), Vector3.UP)
			checker.look_at(Vector3(plr_x, plr_y, plr_z), Vector3.UP)
			velocity = transform.basis * Vector3(0, 0, -move_toward(velocity.length(), SPEED, delta))
			if can_atk:
				if checker.is_colliding():
					var target = checker.get_collider()
					if target != null:
						if target.is_in_group("Player"):
							explode()
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
		explode()
	pass

func explode():
	velocity = Vector3.ZERO
	dead = true
	explosion_animation.play("boom")
	model.visible = false
	await get_tree().create_timer(0.9).timeout
	global_position = Vector3(69420, 69420, 69420)
	await get_tree().create_timer(0.1).timeout
	global_variables.kills = global_variables.kills + 1
	global_variables.enemies_alive = global_variables.enemies_alive - 1
	queue_free()
	pass

func tazer_hit(damage,volts) -> void:
	blood_splash()
	HEALTH -= damage
	status = "Shocked"
	await get_tree().create_timer(volts / 2).timeout
	status = "Normal"
	pass

func di_form_hit(damage, burn) -> void:
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
	blood_splash()
	HEALTH -= dmg
	pass
