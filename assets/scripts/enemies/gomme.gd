extends StaticBody3D


var player = null

@export var HEALTH: int = 12
@export var DAMAGE : int = 4
@export var COOLDOWN : float = 0.5

@export var player_path := "/root/Endless Mode/player"

var balls = load("res://assets/scenes/projectiles/eye.tscn")
var instance
var status : String

@onready var check: RayCast3D = $check
@onready var gibbies: GPUParticles3D = $"Blood Splatter/gibbies"
@onready var blood: GPUParticles3D = $"Blood Splatter/blood"

func _ready() -> void:
	player = get_node(player_path)
	randomize()
	pass


func _process(delta: float) -> void:
	var rng
	rng = randf_range(-3,3)
	if HEALTH > 0 && status != "shocked":
		check.look_at(Vector3(player.global_position.x + rng, player.global_position.y + rng, player.global_position.z + rng), Vector3.UP)
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)


func _physics_process(delta: float) -> void:
		attack()

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

func tri_form_hit(damage, burns):
	blood_splash()
	HEALTH -= damage
	pass



func attack():
	if HEALTH > 0 && status != "stunned":
		if check.is_colliding():
			var target = check.get_collider()
			if target != null:
				if target.is_in_group("Player"):
					instance = balls.instantiate()
					instance.position = check.global_position
					instance.transform.basis = check.global_transform.basis
					player.get_parent().add_child(instance)
					await get_tree().create_timer(COOLDOWN).timeout
