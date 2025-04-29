extends CharacterBody3D


@export var SPEED: float = 5
@export var HEALTH: float = 1
@export var DAMAGE: float = 2

var player = null

@export var player_path := "/root/Endless Mode/player"

@onready var path_finder: NavigationAgent3D = $"path finder"
@onready var animation: AnimationPlayer = $export/animation
@onready var model: Node3D = $export
@onready var check: RayCast3D = $check

@onready var smoke: GPUParticles3D = $explosion/smoke

@onready var gibbies: GPUParticles3D = $"Blood Splatter/gibbies"
@onready var blood: GPUParticles3D = $"Blood Splatter/blood"
@onready var blood_trail: GPUTrail3D = $"Blood Splatter/blood trail"
@onready var explosion_animation: AnimationPlayer = $"explosion/explosion animation"

@onready var explosion_area: Area3D = $"explosion area"
@onready var explosion_collision: CollisionShape3D = $"explosion area/explosion collision"


var ran := RandomNumberGenerator.new()
var dead : bool
var instance
var rng : float

var status : String = "Normal"

var ammo_drop = load("res://assets/scenes/environmental_objects/ammo_drop.tscn")


func _ready() -> void:
	global_variables.enemy_alive += 1
	player = get_node(player_path)
	pass

func _process(delta: float) -> void:
	rng = ran.randf_range(1, 5)
	
	if status != "Normal":
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


func _physics_process(delta: float) -> void:
	print(global_variables.enemy_alive)
	
	instance = ammo_drop.instantiate()
	instance.position = global_position * Vector3(rng, rng, rng)
	
	if HEALTH <= 0:
		dead = true
	
	if !model.visible:
		for body in explosion_area.get_overlapping_bodies():
			if body.is_in_group("Explodable"):
				if body.has_method("exp_damage"):
					body.exp_damage(DAMAGE)
	
	death()
	
	if !dead && status != "Shocked":
		
		if check.is_colliding():
			var target = check.get_collider()
			if target != null:
				if target.is_in_group("Player"):
					explode()
		
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		
		velocity = Vector3.ZERO
		path_finder.set_target_position(player.global_position)
		var next_target = path_finder.get_next_path_position()
		velocity = (next_target - global_position).normalized() * SPEED
		move_and_slide()
	pass

func explode():
	velocity = Vector3.ZERO
	dead = true
	explosion_animation.play("boom")
	model.visible = false
	await get_tree().create_timer(0.9).timeout
	global_variables.enemy_alive -= 1
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

## DAMAGE
func tazer_hit(damage,volts):
	blood_splash()
	HEALTH -= damage
	status = "Shocked"
	await get_tree().create_timer(volts / 2).timeout
	status = "Normal"
	pass

func quad_form_hit(damage, burns):
	pass


func exp_damage(dmg):
	HEALTH -= dmg
	pass
