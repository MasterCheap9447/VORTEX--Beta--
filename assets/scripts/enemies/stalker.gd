extends RigidBody3D


@export var SPEED: float = 1.5 
@export var HEALTH: float = 5
@export var DAMAGE: float = 10

var player = null
var blood_decal = preload("res://assets/scenes/environmental_objects/blood_splater.tscn")
var status : String

@export var player_path : NodePath
@onready var locater: NavigationAgent3D = $locater
@onready var checker: RayCast3D = $checker
@onready var blood_particles: GPUParticles3D = $"blood particles"
@onready var blood_spawn: Node3D = $"blood spawn"
@onready var detect: RayCast3D = $detect
@onready var stun: Timer = $stun
@onready var caste: RayCast3D = $caste
@onready var crunch: AudioStreamPlayer3D = $crunch
@onready var shocked_status_model: MeshInstance3D = $shocked_status

var ran := RandomNumberGenerator.new()

func spawn_blood() -> void:
	var decal = blood_decal.instantiate()
	get_parent().add_child(decal)
	decal.global_transform.origin = blood_spawn.global_transform.origin
	

func _ready() -> void:
	
	
	player = get_node(player_path)

func _physics_process(delta: float) -> void:
	
	if HEALTH > 0:
		if detect.is_colliding():
			if !crunch.playing:
				attack()

func _process(delta: float) -> void:
	if status != "shocked":
		shocked_status_model.visible = false
		if HEALTH > 0 && player != null:
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			locater.set_target_position(player.global_transform.origin)
			var next_target = locater.get_next_path_position()
			apply_impulse((next_target - global_transform.origin).normalized())
	else:
		shocked_status_model.visible = true
	
	if HEALTH <= 0:
		global_variables.kills += 1


## DAMAGE
func tazer_hit(damage,volts):
	blood_particles.emitting = true
	HEALTH -= damage
	if HEALTH > 0:
		status = "shocked"
		stun.wait_time = volts
		stun.start()
	await get_tree().create_timer(0.3).timeout
	blood_particles.emitting = false
	spawn_blood()

func quad_form_hit(damage, burns):
	blood_particles.emitting = true
	HEALTH -= damage
	await get_tree().create_timer(0.3).timeout
	spawn_blood()

func attack() -> void:
	var target = detect.get_collider()
	if target != null:
		if target.is_in_group("Player"):
			if target.has_method("damage"):
				crunch.play()
				target.damage(DAMAGE)
				apply_impulse(transform.basis * Vector3(0, 0, SPEED))


func _on_stun_timeout() -> void:
	status = "normal"
