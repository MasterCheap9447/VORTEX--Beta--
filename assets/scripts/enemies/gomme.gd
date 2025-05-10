extends CharacterBody3D


@export var SPEED: float = 5
@export var HEALTH: float = 5
@export var DAMAGE: float = 2

var player = null

@export var player_path := "/root/Endless Mode/player"

@onready var model: Node3D = $export
@onready var check: RayCast3D = $check

@onready var gibbies: GPUParticles3D = $"Blood Splatter/gibbies"
@onready var blood: GPUParticles3D = $"Blood Splatter/blood"


var eye = load("res://assets/scenes/projectiles/eye.tscn")


var ran := RandomNumberGenerator.new()
var dead : bool
var instance

var status : String = "Normal"


func _ready() -> void:
	global_variables.enemies_alive += 1
	player = get_node(player_path)
	pass

func _process(delta: float) -> void:
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
		dead
		queue_free()
	pass

func blood_splash():
	gibbies.emitting = true
	blood.emitting = true
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
	status = "Burned"
	status = "Shocked"
	await get_tree().create_timer(3).timeout
	status = "Normal"
	pass

func exp_damage(dmg, pos)  -> void:
	blood_splash()
	HEALTH -= dmg * 2
	pass



func _on_cooldown_timeout() -> void:
	if !dead && status != "Shocked":
		attack()
	pass
