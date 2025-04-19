extends CharacterBody3D


@export var SPEED: float = 0.1
@export var HEALTH: float = 2
@export var DAMAGE: float = 10

var player = null

@export var player_path : NodePath

@onready var check: RayCast3D = $check
@onready var flash: GPUParticles3D = $flash
@onready var sparks: GPUParticles3D = $sparks

var ran := RandomNumberGenerator.new()

func spawn_blood() -> void:
	pass
	

func _ready() -> void:
	player = get_node(player_path)
	pass

func _process(delta: float) -> void:
	if check.is_colliding():
		var target = check.get_collider()
		if target.is_in_group("Player"):
			explode()
	
	pass

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y -= 12
	
	check.look_at(Vector3(player.global_position.x, player.global_position.y, player.global_position.z), Vector3.UP)
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	position.x = move_toward(position.x, player.global_position.x, SPEED)
	position.z = move_toward(position.z, player.global_position.z, SPEED)
	pass

func explode() -> void:
	velocity = Vector3.ZERO
	position = Vector3.ZERO
	sparks.emitting = true
	flash.emitting = true
	await get_tree().create_timer(0.5).timeout
	queue_free()
	pass


## DAMAGE
func tazer_hit(damage,volts):
	pass

func quad_form_hit(damage, burns):
	pass
