extends CharacterBody3D



### SIGNALS ###
signal change_to_tri_form
signal change_to_tazer
signal change_to_amplifier


### VARIABLES ###
var wish_direction = Vector3.ZERO
var ran = RandomNumberGenerator.new()
var spawn_point = Vector3(0.0, 12.0, 0.0)
var weapon_number: int = 1
var is_dashing: bool = false
var wall_jump_count: float = 0.0
var volume:float = 0.0
var speed


## SCENE NODES
@onready var tazer_crosshair: TextureRect = $"UI/tazer crosshair"
@onready var tri_form_crosshair: TextureRect = $"UI/tri form crosshair"

@onready var neck: Node3D = $NECK
@onready var camera: Camera3D = $NECK/camera
@onready var gun_camera: Camera3D = $"UI/viewport/sub viewport/gun_camera"

@onready var fuel_bar: TextureProgressBar = $"UI/container/fuel"
@onready var fuel_percentage: RichTextLabel = $UI/container/fuel/percentage
@onready var revv: AudioStreamPlayer3D = $revv

@onready var tri_form: Node3D = $NECK/camera/WEAPONS/tri_form
@onready var tazer: Node3D = $NECK/camera/WEAPONS/tazer
@onready var amplifier: Node3D = $NECK/camera/WEAPONS/amplifier

@onready var checker: RayCast3D = $NECK/RAYS/checker
@onready var left_checker: RayCast3D = $"NECK/RAYS/left checker"
@onready var right_checker: RayCast3D = $"NECK/RAYS/right checker"


### EXPORT VARIABLES ###
@export_group("MOVEMENT VARIABLES")
@export_subgroup("Ground Movement Variables")
@export_range(6,14) var JUMP_FORCE: float = 10.0

@export_subgroup("Aerial Movement Variables")
@export_range(0,5) var THRUST_FORCE: float = 8.0
@export_range(60, 140) var SLAM_FORCE: float = 80.0

@export_group("GENERAL")
@export var FUEL: float = 200.0
@export var HEALTH: float = 100.0


### CONSTANTS ###
const THRUSTER_CONSUMPTION: float = 0.25
const SLAM_CONSUMPTION: float = 10.0
const MAX_THRUST_SPEED: float = 7.5


### GENERAL FUNCTIONING ###
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("0"):
		damage(1)
	
	$"NECK/Flame/Thrust Particle".speed_scale = velocity.length() / 4
	$"NECK/Flame/Thrust Flame".speed_scale = velocity.length() / 4
	$"NECK/Flame/Thrust Smoke".speed_scale = velocity.length() / 4
	$"NECK/Flame/Thrust Flare".speed_scale = velocity.length() / 4
	
	$pump.pitch_scale = ran.randf_range(1,3)
	$clank.pitch_scale = ran.randf_range(1,3)
	
	## Fuel
	FUEL = clamp(FUEL, 0.0, 200.0)
	fuel_bar.value = FUEL
	fuel_percentage.text = str(ceil(FUEL),"%")
	
	## Gun camera and Normal camera Relation
	gun_camera.set_global_transform(camera.get_global_transform())
	gun_camera.fov = 75


### GOOFY AH CODE I AINT TOUCHINIG ###
func _ready() -> void:
	global_position = spawn_point
	clamp(JUMP_FORCE, 10.0, 20.0)
	ran.randomize()
	gun_camera.global_transform.basis = camera.global_transform.basis
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


### MOVEMENT IMPLEMENTATION ###
func _physics_process(delta: float) -> void:

	## Directional Variables
	var input_direction := Input.get_vector("left", "right", "forward", "backward").normalized()
	wish_direction = (neck.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	## Jumping Control
	if is_on_floor():
		wall_jump_count = 3
		if Input.is_action_just_pressed("jump"):
			var jump_direction = Vector3(wish_direction.x, 1, wish_direction.z)
			velocity += JUMP_FORCE * jump_direction
			$pump.play()
	if is_on_wall_only():
		var wall_normal = get_wall_normal().normalized()
		if Input.is_action_just_pressed("jump"):
			if wall_jump_count <= 3:
				velocity = (wall_normal) * JUMP_FORCE
				velocity.y = JUMP_FORCE * 4
				wall_jump_count -= 1
				$pump.play()
			else:
				velocity = (wall_normal) * JUMP_FORCE / 3
	
	## Jump Buffering
	if !is_on_floor():
		if Input.is_action_just_pressed("jump"):
			print("Start timer")
			$buffer.start()
	if !$buffer.is_stopped():
		if is_on_floor():
			print("jump")
			var jump_direction = Vector3(wish_direction.x, 1, wish_direction.z)
			velocity += JUMP_FORCE * jump_direction
			$pump.play()
	
	## Control Movement
	if is_on_floor():
		wall_jump_count = 0
		camera.rotation.z = clamp(camera.rotation.z, 0.0, 0.25)
	elif is_on_wall_only():
		velocity.y = -24
	
	move_and_slide()


func _unhandled_input(_event: InputEvent) -> void:
	## Weapon Changing
	if Input.is_action_just_pressed("0"):
		change_to_amplifier.emit()
		tazer_crosshair.visible = false
		tazer.visible = false
		tri_form_crosshair.visible = false
		tri_form.visible = false
		amplifier.visible = true
	if Input.is_action_just_pressed("1"):
		change_to_tazer.emit()
		tazer_crosshair.visible = true
		tazer.visible = true
		tri_form_crosshair.visible = false
		tri_form.visible = false
		amplifier.visible = false
	if Input.is_action_just_pressed("2"):
		change_to_tri_form.emit()
		weapon_number = 2
		tri_form.visible = true
		tri_form_crosshair.visible = true
		tazer_crosshair.visible = false
		tazer.visible = false
		amplifier.visible = false


## DAMAGE
func damage(_poison):
	var pick = ran.randi_range(0,12)
	if pick >= 4:
		if pick%2 == 0:
			$"UI/health/left arm".visible = false
		else:
			$"UI/health/right arm".visible = false
	elif pick <= 5 && pick >= 10:
		if pick%2 == 0:
			$"UI/health/right leg".visible = false
		else:
			$"UI/health/left leg".visible = false
	elif pick == 11:
		$UI/health/head.visible = false
	else:
		$UI/health/chest.visible = false
	pass



func _goofy_air_physics(delta) -> void:
	if wish_direction:
		if is_on_floor():
			velocity.x = wish_direction.x * THRUST_FORCE / 2
			velocity.z = wish_direction.z * THRUST_FORCE / 2
		else:
			velocity.x = lerp(velocity.x, wish_direction.x * THRUST_FORCE/2, delta * 8)
			velocity.z = lerp(velocity.z, wish_direction.z * THRUST_FORCE/2, delta * 8)
	else:
		velocity.x = move_toward(velocity.x, 0.0, delta * 8)
		velocity.z = move_toward(velocity.z, 0.0, delta * 8)
	pass
