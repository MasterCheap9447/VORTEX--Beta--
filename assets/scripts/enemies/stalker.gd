extends RigidBody3D


@export var SPEED: float = 1.0
@export var HEALTH: float = 5
@export var DAMAGE: float = 1

var player = null
var status : String

@export var player_path := "/root/Endless Mode/player"

@onready var gibbies: GPUParticles3D = $"Blood Splatter/gibbies"
@onready var blood: GPUParticles3D = $"Blood Splatter/blood"
@onready var locater: NavigationAgent3D = $locater
@onready var checker: RayCast3D = $checker
@onready var detect: RayCast3D = $detect
@onready var stun: Timer = $stun
@onready var caste: RayCast3D = $caste
@onready var crunch: AudioStreamPlayer3D = $crunch
@onready var shocked_status_model: MeshInstance3D = $shocked_status

var ran := RandomNumberGenerator.new()


func _ready() -> void:
	global_variables.enemy_alive += 1
	shocked_status_model.visible = false
	player = get_node(player_path)

func _physics_process(_delta: float) -> void:
	
	if HEALTH > 0:
		if detect.is_colliding():
			if !crunch.playing:
				attack()

func _process(_delta: float) -> void:
	if status != "shocked":
		shocked_status_model.visible = false
		if HEALTH > 0:
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			apply_impulse(transform.basis * Vector3(0, 0, -SPEED))
	else:
		shocked_status_model.visible = true
	
	if HEALTH <= 0:
		global_variables.kills += 1
		global_variables.enemy_alive -= 1
		queue_free()


func blood_splash():
	blood.emitting = true
	gibbies.emitting = true
	pass

## DAMAGE
func tazer_hit(damage,volts):
	blood_splash()
	HEALTH -= damage
	status = "Shocked"
	await get_tree().create_timer(volts / 2).timeout
	status = "Normal"
	pass

func tri_form_hit(damage, burns):
	blood_splash()
	HEALTH -= damage
	pass

func attack() -> void:
	var target = detect.get_collider()
	if target != null:
		if target.is_in_group("Player"):
			if target.has_method("nrml_damage"):
				crunch.play()
				target.nrml_damage(DAMAGE)
				apply_impulse(transform.basis * Vector3(0, 0, SPEED))
				await get_tree().create_timer(0.2).timeout
	pass

func exp_damage(damage):
	HEALTH -= damage * 1.5
	pass

func _on_stun_timeout() -> void:
	status = "normal"
	pass
