extends CharacterBody3D



### SIGNALS ###
signal change_to_tri_form
signal change_to_tazer
signal change_to_amplifier


### VARIABLES ###
var headbob_time: float = 0.0
var wish_direction = Vector3.ZERO
var ran = RandomNumberGenerator.new()
var spawn_point = Vector3(0.0, 12.0, 0.0)
var weapon_number: int = 1
var is_sliding: bool = false
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
@export_group("CAMERA VARIABLES")
@export_range(0.0001, 0.001) var SENSITIVITY: float = 0.005
@export_range(70,140) var FOV: int = 110
@export_range(0,50) var FOV_CHANGE: int = 25

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
@export_range(0,5) var THRUST_FORCE: float = 8.0
@export_range(60, 140) var SLAM_FORCE: float = 80.0
@export_range(20,80) var AIR_FRICTION: float = 40.0

@export_group("GENERAL")
@export var FUEL: float = 100.0


### CONSTANTS ###
const HEADBOB_AMPLITUDE: float = 0.08
const HEADBOB_FREQUENCY: float = 1.5
const DASH_CONSUMPTION: float = 7.0
const THRUSTER_CONSUMPTION: float = 0.25
const SLAM_CONSUMPTION: float = 10.0
const MAX_THRUST_SPEED: float = 7.5


### GENERAL FUNCTIONING ###
func _process(delta: float) -> void:
	
	$"NECK/Flame/Thrust Particle".speed_scale = velocity.length() / 4
	$"NECK/Flame/Thrust Flame".speed_scale = velocity.length() / 4
	$"NECK/Flame/Thrust Smoke".speed_scale = velocity.length() / 4
	$"NECK/Flame/Thrust Flare".speed_scale = velocity.length() / 4
	
	$pump.pitch_scale = ran.randf_range(1,3)
	$clank.pitch_scale = ran.randf_range(1,3)
	
	var clamped_velocity = clamp(velocity.length(), 2, MAX_THRUST_SPEED)
	JUMP_FORCE = 10 * clamped_velocity 
	JUMP_FORCE = clamp(JUMP_FORCE, 12, 15)
	
	#print(wish_direction)
	## Fuel
	FUEL = clamp(FUEL, 0.0, 100.0)
	fuel_bar.value = FUEL
	fuel_percentage.text = str(ceil(FUEL),"%")
	
	## Gun camera and Normal camera Relation
	gun_camera.set_global_transform(camera.get_global_transform())


### GOOFY AH CODE I AINT TOUCHINIG ###
func _ready() -> void:
	global_position = spawn_point
	clamp(JUMP_FORCE, 10.0, 20.0)
	ran.randomize()
	gun_camera.global_transform.basis = camera.global_transform.basis
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


### MOVEMENT IMPLEMENTATION ###
func _physics_process(delta: float) -> void:
	
	volume = clamp(volume,-100, -40)
	revv.volume_db = -volume
	#print(volume)
	
	## Directional Variables
	var input_direction := Input.get_vector("left", "right", "forward", "backward").normalized()
	wish_direction = (neck.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	## Edge Friction
	if $"NECK/RAYS/floor checker".is_colliding():
		if !$"NECK/RAYS/air checker".is_colliding():
			GROUND_DECELERATION = 16.0
			GROUND_FRICTION = 10.0
		else:
			GROUND_DECELERATION = 14.0
			GROUND_FRICTION = 8.0
	
	## Thrust Implementation
	if FUEL >= THRUSTER_CONSUMPTION:
		if Input.is_action_just_pressed("thrust"):
			volume = move_toward(volume, 140.0, delta * 4)
			$"NECK/Flame/Thrust Flame".emitting = true
			$"NECK/Flame/Thrust Particle".emitting = true
			$"NECK/Flame/Thrust Smoke".emitting = true
			$"NECK/Flame/Thrust Flare".emitting = true
			revv.play()
		if !Input.is_action_pressed("thrust"):
			volume = move_toward(volume, 0.0, delta * 4)
			$"NECK/Flame/Thrust Flame".emitting = false
			$"NECK/Flame/Thrust Particle".emitting = false
			$"NECK/Flame/Thrust Smoke".emitting = false
			$"NECK/Flame/Thrust Flare".emitting = false
			revv.stream_paused = true
		if Input.is_action_pressed("thrust"):
			handle_thruster(delta, wish_direction)
		elif Input.is_action_just_released("thrust"):
			velocity.y = 0
	## Dash Implementation
	if FUEL >= DASH_CONSUMPTION:
		if Input.is_action_just_pressed("dash"):
			if wish_direction:
				velocity = wish_direction * DASH_FORCE
				FUEL -= DASH_CONSUMPTION
				is_dashing = true
				await get_tree().create_timer(0.3).timeout
				is_dashing = false
			if !wish_direction:
				velocity = neck.transform.basis * Vector3(0,0,-DASH_FORCE)
				FUEL -= DASH_CONSUMPTION
				is_dashing = true
				await get_tree().create_timer(0.3).timeout
				is_dashing = false
	## Slam Implementation
	if FUEL >= SLAM_CONSUMPTION:
		if Input.is_action_just_pressed("slide"):
			if !is_on_floor():
				is_sliding = false
				velocity.y = -SLAM_FORCE
				FUEL -= SLAM_CONSUMPTION
	## Slide Implementation
	if FUEL > 0:
		if Input.is_action_pressed("slide"):
			is_sliding = true
	else:
		volume = move_toward(volume, 0.0, delta * 4)
		is_sliding = false
		$"NECK/Flame/Thrust Flame".emitting = false
		$"NECK/Flame/Thrust Particle".emitting = false
		$"NECK/Flame/Thrust Smoke".emitting = false
		$"NECK/Flame/Thrust Flare".emitting = false
		revv.stream_paused = true
	if !Input.is_action_pressed("slide"):
		is_sliding = false
	
	## Jumping Control
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			var jump_direction = Vector3(wish_direction.x, 1, wish_direction.z).normalized()
			velocity += JUMP_FORCE * jump_direction
			$pump.play()
	elif is_on_wall_only():
		var wall_normal = (get_wall_normal()).normalized()
		if Input.is_action_just_pressed("jump"):
			if wall_jump_count <= 3:
				velocity = (wall_normal) * JUMP_FORCE / 1.5
				velocity.y += JUMP_FORCE
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
			var jump_direction = Vector3(wish_direction.x, 1, wish_direction.z).normalized()
			velocity += JUMP_FORCE * jump_direction
			$pump.play()
	
	## Control Movement
	if is_on_floor():
		camera.rotation.z = clamp(camera.rotation.z, 0.0, 0.25)
		if is_sliding:
			velocity = (neck.transform.basis) * Vector3(0, 0, -SLIDE_SPEED)
			camera.rotation.z = move_toward(camera.rotation.z, 0.25, delta)
			speed = move_toward(velocity.length(), SLIDE_SPEED, delta*4)
			scale = lerp(scale, Vector3(1,0.45,1), delta * 8)
			if Input.is_action_just_pressed("jump"):
				velocity.y = JUMP_FORCE * 2
		else:
			speed = SPEED
			scale = lerp(scale, Vector3(1,1,1), delta * 8)
			camera.rotation.z = move_toward(camera.rotation.z, 0.0, delta)
		wall_jump_count = 0
		if !is_sliding:
			handle_ground_physics(delta)
	elif is_on_wall_only():
		velocity.y = -2.4
	elif !is_on_floor() && !is_on_wall():
		handle_air_physics(delta)
	
	if is_dashing:
		velocity.y = 0
	else:
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
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
	#HEALTH -= poison * 5
	#if HEALTH <= 0:
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#get_tree().change_scene_to_file("res://assets/scenes/death_screen.tscn")
	pass


### HANDLING THRUSTER ###
func handle_thruster(delta:float, dir:Vector3) -> void:
	## Thrust
	velocity.y = clamp(velocity.y, -9999999999999, MAX_THRUST_SPEED)
	velocity.y += THRUST_FORCE
	FUEL -= THRUSTER_CONSUMPTION
	if dir:
		velocity += neck.transform.basis * Vector3(0,0,-MAX_THRUST_SPEED * 10) * delta
	else:
		self.velocity.x = move_toward(velocity.x, 0.0, delta * 12)
		self.velocity.z = move_toward(velocity.z, 0.0, delta * 12)
	$clank.stop()
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
	$clank.stop()
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
	if !$clank.playing:
		if velocity.length() != 0:
			$clank.play()
		else:
			$clank.stop()
	
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
	$clank.stop()
	pass



### CAMERA ANIMATIONS ###
func _headbob_effect(delta):
	var x = cos(headbob_time * HEADBOB_FREQUENCY/2) * HEADBOB_AMPLITUDE
	var y = sin(headbob_time * HEADBOB_FREQUENCY) * HEADBOB_AMPLITUDE
	headbob_time += delta * velocity.length()
	camera.transform.origin = Vector3(x, y, 0)
	pass
func _fov_alter(delta):
	var velocity_clamped = clamp(velocity.length(), 0.5, MAX_THRUST_SPEED * 4)
	var target_fov = FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta)
	pass


func _on_buffer_timeout() -> void:
	#if is_on_floor():
		#print("jump")
		#var jump_direction = Vector3(wish_direction.x, 1, wish_direction.z).normalized()
		#velocity += JUMP_FORCE * jump_direction
		#$pump.play()
	pass
