extends CharacterBody3D


@export var SPEED: float = 5
@export var HEALTH: float = 1
@export var DAMAGE: float = 1

var player = null

@export var player_path := "/root/Endless Mode/player"

@onready var path_finder: NavigationAgent3D = $"path finder"
@onready var animation: AnimationPlayer = $export/animation
@onready var model: Node3D = $export
@onready var check: RayCast3D = $check

@onready var smoke: GPUParticles3D = $explosion/smoke

@onready var gibbies: GPUParticles3D = $"Blood Splatter/gibbies"
@onready var blood: GPUParticles3D = $"Blood Splatter/blood"
@onready var explosion_animation: AnimationPlayer = $"explosion/explosion animation"

@onready var explosion_area: Area3D = $"explosion area"
@onready var explosion_collision: CollisionShape3D = $"explosion area/explosion collision"


var ran := RandomNumberGenerator.new()
var dead : bool
var instance
var player_position : Vector3

var status : String = "Normal"


func _ready() -> void:
	global_variables.enemies_alive += 1
	player = get_node(player_path)
	pass

func _process(_delta: float) -> void:
	
	if status == "":
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
	
	#instance = ammo_drop.instantiate()
	#instance.position = global_position * Vector3(rng, rng, rng)
	
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
			velocity = transform.basis * Vector3(0, 0, -SPEED)
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			if check.is_colliding():
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
	global_variables.kills = global_variables.kills + 1
	global_variables.enemies_alive = global_variables.enemies_alive - 1
	queue_free()
	pass

func death():
	if HEALTH <= 0:
		explode()
	pass

func blood_splash():
	gibbies.emitting = true
	blood.emitting = true
	pass

func tazer_hit(damage,volts):
	blood_splash()
	HEALTH -= damage
	status = "Shocked"
	await get_tree().create_timer(volts / 2).timeout
	status = "Normal"
	pass

func tri_form_hit(damage, burns) -> void:
	blood_splash()
	HEALTH -= damage * 2
	pass

func exp_damage(dmg, pos)  -> void:
	blood_splash()
	HEALTH -= dmg * 2
	pass
