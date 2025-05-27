extends CharacterBody3D



signal add_kill

@export var SPEED: float = 3
@export var HEALTH: float = 1
@export var DAMAGE: float = 1

var player = null
var world = null

@export var player_path := "/root/Endless Mode/player"
@export var world_path := "/root/Endless Mode"

@onready var mesh: Node3D = $mesh
@onready var model_animation: AnimationPlayer = $"mesh/model animation"
@onready var check: RayCast3D = $check
@onready var navigator: NavigationAgent3D = $navigator

@onready var explosion_animation: AnimationPlayer = $"Light Explosion/explosion animation"
@onready var explosion_area: Area3D = $"explosion area"


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
	SPEED = 3 * global_variables.difficulty
	
	model_animation.play("spawning")
	pass

func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	death()
	
	if !mesh.visible:
		for body in explosion_area.get_overlapping_bodies():
			if body.is_in_group("Xplodable"):
				body.exp_damage(DAMAGE, explosion_area.global_position)
	
	if dead == false:
		collision_layer = 1
		collision_mask = 1
		if status != "Shocked":
			if !model_animation.is_playing():
				model_animation.play("walk")
			if is_on_floor():
				navigator.set_target_position(player.global_position)
				var next_target = navigator.get_next_path_position()
				velocity = (next_target - global_position).normalized() * SPEED
				if !model_animation.is_playing():
					model_animation.play("walk")
			else:
				velocity -= transform.basis * Vector3(0, 12, 0)
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			
			if can_atk:
				if check.is_colliding():
					var target = check.get_collider()
					if target != null:
						if target.is_in_group("Player"):
							explode()
							await get_tree().create_timer(0.2).timeout
		else:
			model_animation.play("shocked")
	else:
		velocity = Vector3.ZERO
		collision_layer = 4
		collision_mask = 4
	
	move_and_slide()
	pass

func explode():
	dead == true
	velocity = Vector3.ZERO
	model_animation.play("explode")
	await get_tree().create_timer(0.5).timeout
	mesh.visible = false
	explosion_animation.play("BOOM")
	await get_tree().create_timer(1).timeout
	queue_free()
	pass

func death():
	if HEALTH <= 0:
		velocity = Vector3.ZERO
		var ran = randi_range(1,2)
		if dead == false:
			if ran == 1:
				model_animation.play("death 1")
			if ran == 2:
				model_animation.play("death 2")
			world.add_kill()
			dead = true
		else:
			return
	pass

func blood_splash():
	$"Blood Splash/blood animation".play("blood splash")
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
	blood_splash()
	HEALTH -= damage
	status = "Shocked"
	volts = clamp(volts, 3/4, 5.0)
	await get_tree().create_timer(volts).timeout
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
