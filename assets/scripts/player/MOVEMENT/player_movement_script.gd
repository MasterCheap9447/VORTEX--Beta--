extends CharacterBody3D



### SIGNALS ###
signal change_to_tri_form
signal change_to_tazer


### VARIABLES ###
var headbob_time: float = 0.0
var wish_direction = Vector3.ZERO
var ran = RandomNumberGenerator.new()
var spawn_point = Vector3(0.0, 12.0, 0.0)
var weapon_number: int = 1
var is_sliding: bool = false
var wall_jump_count: float = 0.0
var air_jump_count: float = 0.0
var lift
var speed


## SCENE NODES
@onready var tazer_crosshair: TextureRect = $"UI/tazer crosshair"
@onready var tri_form_crosshair: TextureRect = $"UI/quad form crosshair"

@onready var neck: Node3D = $NECK
@onready var camera: Camera3D = $NECK/camera
@onready var gun_camera: Camera3D = $"UI/viewport/sub viewport/gun_camera"

@onready var health_bar: ProgressBar = $"UI/health bar"
@onready var stamina_visual: AnimatedSprite2D = $"UI/health bar/stamina visual"
@onready var stamina_recharge: Timer = $stamina_recharge

@onready var tri_form: Node3D = $NECK/camera/WEAPONS/tri_form
@onready var tazer: Node3D = $NECK/camera/WEAPONS/tazer

@onready var checker: RayCast3D = $NECK/RAYS/checker
@onready var left_checker: RayCast3D = $"NECK/RAYS/left checker"
@onready var right_checker: RayCast3D = $"NECK/RAYS/right checker"


### EXPORT VARIABLES ###
@export_group("CAMERA VARIABLES")
@export_range(0.0001, 0.001) var SENSITIVITY: float = 0.005
@export_range(70,140) var FOV: int = 110

@export_group("MOVEMENT VARIABLES")

@export_subgroup("Ground Movement Variables")
@export_range(20,26) var SLIDE_SPEED: float = 24.0
@export_range(12,20) var SPEED: float = 16.0
@export_range(18,22) var GROUND_ACCELERATION : float = 20.0
@export_range(12,16) var GROUND_DECELERATION : float = 14.0
@export_range(6,10) var GROUND_FRICTION : float = 8.0
@export_range(6,14) var JUMP_FORCE: float = 10.0
@export_range(26,34) var DASH_FORCE: float = 30.0

@export_subgroup("Aerial Movement Variables")
@export_range(0.5,1) var AIR_CAP: float = 0.85
@export_range(750,900) var AIR_ACCELERATION: float = 800.0
@export_range(450,600) var AIR_SPEED: float = 500.0
@export_range(1,5) var THRUST_FORCE: float = 8.0
@export_range(60, 140) var SLAM_FORCE: float = 80.0
@export_range(20,80) var AIR_FRICTION: float = 40.0

@export_group("GENERAL")
@export var FUEL: float = 100.0


### CONSTANTS ###
const HEADBOB_AMPLITUDE: float = 0.08
const HEADBOB_FREQUENCY: float = 1.5
const DASH_CONSUMPTION: float = 1.0
const THRUSTER_CONSUMPTION: float = 0.15
const SLAM_CONSUMPTION: float = 1.5
const MAX_THRUST_SPEED: float = 2.0


### GENERAL FUNCTIONING ###
func _process(_delta: float) -> void:
	print(wish_direction)
	## Fuel
	FUEL = clamp(FUEL, 0.0, 100.0)
	health_bar.value = FUEL
	
	## Gun camera and Normal camera Relation
	gun_camera.set_global_transform(camera.get_global_transform())


### GOOFY AH CODE I AINT TOUCHINIG ###
func _ready() -> void:
	change_to_tazer.emit()
	tazer_crosshair.visible = true
	tazer.visible = true
	tri_form_crosshair.visible = false
	tri_form.visible = false
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
	
	## Dash Implement
	if Input.is_action_just_pressed("dash") && FUEL>0.0:
		velocity = neck.transform.basis * Vector3(0.0, 0.0, -DASH_FORCE)
		FUEL -= DASH_CONSUMPTION
	if FUEL > 0.0:
		## Dash Implamentation
		if Input.is_action_just_pressed("dash"):
			velocity = neck.transform.basis * Vector3(0.0, 0.0, -DASH_FORCE)
			FUEL -= DASH_CONSUMPTION
		if Input.is_action_pressed("slide"):
			## Slam Implementation
			if is_on_floor():
				is_sliding = true
			elif !is_on_floor():
				velocity.y = -SLAM_FORCE
				FUEL -= SLAM_CONSUMPTION
		else:
			is_sliding = false
	
	## Control Movement
	if is_on_floor():
		if is_sliding:
			speed = move_toward(speed, SLIDE_SPEED, delta*4)
			scale = lerp(scale, Vector3(1,0.5,1), delta * 8)
		else:
			speed = SPEED
			scale = lerp(scale, Vector3(1,1,1), delta * 8)
		wall_jump_count = 0
		air_jump_count = 0
		if !is_sliding:
			handle_ground_physics(delta)
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_FORCE
		if Input.is_action_just_pressed("slide"):
			velocity = (neck.transform.basis) * Vector3(0, 0, -SLIDE_SPEED)
			is_sliding = true
	elif is_on_wall_only():
		velocity.y = -2.4
		var wall_normal = (get_wall_normal()).normalized()
		if Input.is_action_just_pressed("jump"):
			if wall_jump_count <= 3:
				velocity = (wall_normal) * JUMP_FORCE / 1.5
				velocity.y += JUMP_FORCE
				wall_jump_count += 1
			else:
				velocity = (wall_normal) * JUMP_FORCE / 3
	elif !is_on_floor() && !is_on_wall():
		if Input.is_action_just_pressed("jump") && air_jump_count < 1:
			velocity.y = JUMP_FORCE
			air_jump_count += 1
		handle_air_physics(delta)
	
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	## Capturing the Mouse
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif Input.is_action_pressed("exit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	## Controling the Camera with the Mouse
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * SENSITIVITY)
			camera.rotate_x(-event.relative.y * SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(120))
	
	## Weapon Changing
	if Input.is_action_just_pressed("1"):
		change_to_tazer.emit()
		tazer_crosshair.visible = true
		tazer.visible = true
		tri_form_crosshair.visible = false
		tri_form.visible = false
	if Input.is_action_just_pressed("2"):
		change_to_tri_form.emit()
		weapon_number = 2
		tri_form.visible = true
		tri_form_crosshair.visible = true
		tazer_crosshair.visible = false
		tazer.visible = false


## DAMAGE
func damage(_poison):
	#HEALTH -= poison * 5
	#if HEALTH <= 0:
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#get_tree().change_scene_to_file("res://assets/scenes/death_screen.tscn")
	pass


### HANDLING THRUSTER ###
func handle_thruster(delta:float, dir:Vector3) -> void:
	## Thrust
	velocity.y = THRUST_FORCE
	FUEL -= THRUSTER_CONSUMPTION
	if dir:
		self.velocity.x = move_toward(velocity.x, THRUST_FORCE, delta)
		self.velocity.z = move_toward(velocity.z, THRUST_FORCE, delta)
		FUEL -= THRUSTER_CONSUMPTION/2
	else:
		self.velocity.x = move_toward(velocity.x, 0.0, delta * 12)
		self.velocity.z = move_toward(velocity.z, 0.0, delta * 12)
	pass


### HANDLING ALL MEDIUM MOVEMENTS ###
func handle_air_physics(delta) -> void:
	camera.rotation.z = 0.0
	velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	var cur_speed_in_wish_direction = velocity.dot(wish_direction)
	var capped_speed = min((AIR_SPEED*wish_direction).length(), AIR_CAP)
	var add_speed_till_cap = (capped_speed - cur_speed_in_wish_direction)
	if add_speed_till_cap > 0:
		var acceleration_speed = AIR_ACCELERATION * AIR_SPEED * delta
		acceleration_speed = min(acceleration_speed, add_speed_till_cap)
		velocity += acceleration_speed * wish_direction 
	pass

func handle_ground_physics(delta) -> void:
	var cur_speed_in_wish_direction = velocity.dot(wish_direction)
	var addd_speed_till_cap = speed - cur_speed_in_wish_direction
	if addd_speed_till_cap > 0:
		var accel_speed = GROUND_ACCELERATION * delta * speed
		accel_speed = min(accel_speed, addd_speed_till_cap)
		velocity += accel_speed * wish_direction
	_headbob_effect(delta)
	camera.rotation.z = 0.0
	
	var control = max(velocity.length(), GROUND_DECELERATION)
	var drop = control * GROUND_FRICTION * delta
	var new_speed = max(velocity.length() - drop, 0.0)
	if velocity.length() > 0:
		new_speed /= velocity.length()
	velocity *= new_speed
	pass

func handle_wall_physics(_delta) -> void:
	velocity.x = wish_direction.x * SPEED
	velocity.z = wish_direction.z * SPEED
	# left side
	if left_checker.is_colliding():
		camera.rotation.z = -0.1
		if Input.is_action_pressed("left"):
			velocity.y = SPEED / 2
		if Input.is_action_pressed("right"):
			velocity.y = -SPEED / 2
	# right side
	if right_checker.is_colliding():
		camera.rotation.z = 0.1
		if Input.is_action_pressed("left"):
			velocity.y = -SPEED / 2
		if Input.is_action_pressed("right"):
			velocity.y = SPEED / 2
	pass



### CAMERA ANIMATIONS ###
func _headbob_effect(delta):
	var x = cos(headbob_time * HEADBOB_FREQUENCY/2) * HEADBOB_AMPLITUDE
	var y = sin(headbob_time * HEADBOB_FREQUENCY) * HEADBOB_AMPLITUDE
	headbob_time += delta * velocity.length()
	camera.transform.origin = Vector3(x, y, 0)
	pass
func _fov_alter(delta):
	var velocity_clamped = clamp(velocity.length(), 0.5, SLIDE_SPEED)
	var target_fov = FOV + 1 * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, 12 * delta)
	pass


func _on_stamina_recharge_timeout() -> void:
	#if is_on_floor():
		#stamina += 1
	pass
