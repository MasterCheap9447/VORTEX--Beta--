extends RigidBody3D


@export var HEALTH: int = 12
@export var player : Node3D
@export var DAMAGE : int = 4
@export var COOLDOWN : float = 0.5

var blood_decal = preload("res://assets/scenes/environmental_objects/blood_splater.tscn")
var balls = load("res://assets/scenes/projectiles/eyes.tscn")
var instance
var status : String

@onready var blood_spawn: Node3D = $"blood spawn"
@onready var check: RayCast3D = $check
@onready var blood_particles: GPUParticles3D = $"blood particles"
@onready var stun: Timer = $stun

func spawn_blood() -> void:
	var decal = blood_decal.instantiate()
	get_parent().add_child(decal)
	decal.global_transform.origin = blood_spawn.global_transform.origin


func _process(delta: float) -> void:
	if HEALTH > 0 && status != "shocked":
		check.look_at(Vector3(player.global_position.x, player.global_position.y, player.global_position.z), Vector3.UP)
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)


func _physics_process(delta: float) -> void:
		attack()

## DAMAGE
func tazer_hit(damage,volts):
	blood_particles.emitting = true
	HEALTH -= damage
	if HEALTH > 0:
		status = "shocked"
		stun.wait_time = volts
		stun.start()
	await get_tree().create_timer(0.3).timeout
	spawn_blood()

func quad_form_hit(damage, burns):
	blood_particles.emitting = true
	HEALTH -= damage
	await get_tree().create_timer(0.3).timeout
	spawn_blood()


func attack():
	if HEALTH > 0 && status != "stunned":
		if check.is_colliding():
			var target = check.get_collider()
			if target != null:
				if target.is_in_group("Player"):
					instance = balls.instantiate()
					instance.position = check.global_position
					instance.transform.basis = check.global_transform.basis
					get_parent().add_child(instance)
					await get_tree().create_timer(COOLDOWN).timeout
