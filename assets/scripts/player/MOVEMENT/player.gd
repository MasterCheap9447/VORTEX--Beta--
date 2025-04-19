extends CharacterBody3D



@export var WALK_SPEED : float = 16.0
@export var GROUND_ACCELERATION : float = 4.0
@export var JUMP_FORCE : float = 12.0
@export var AIR_CAP : float = 0.85
@export var AIR_SPEED : float = 500.0
@export var AIR_ACCELERATION : float = 800.0
@export var SLAM_FORCE : float = 100.0
@export var SLIDE_MAX_SPEED : float = 24.0
@export var SLIDE_ACCELERATION : float = 0.5
@export var DASH_FORCE : float = 48.0
@export var THRUST : float = 5.0
@export var MAX_THRUST : float = 50.0
@export var FUEL : float = 200.0


@export var SENSITIVITY : float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@onready var CAMERA: Camera3D = $NECK/camera
@onready var NECK: Node3D = $NECK
@onready var SLIDE_DIRECTION: Node3D = $"slide direction"
@onready var BUFFER: Timer = $buffer
@onready var GUN_CAMERA: Camera3D = $"UI/viewport/sub viewport/gun_camera"
@onready var WEAPONS: Node3D = $NECK/camera/WEAPONS
@onready var scrath_vfx: GPUParticles3D = $"slide direction/Scraps/Scrath VFX"

@onready var tazer_crosshair: TextureRect = $"UI/tazer crosshair"
@onready var tri_form_crosshair: TextureRect = $"UI/tri form crosshair"

@onready var fuel: TextureProgressBar = $UI/container/Control/fuel
@onready var percentage: RichTextLabel = $UI/container/Control/fuel/percentage


var air_jump_no : int = 0
var wall_jump_no : int = 0
var is_dashing : bool = false
var is_slamming : bool = false
var is_sliding : bool = false
var weapon_sway : float = 5
var weapon_rotate : float = 0.005
var mouse_input : Vector2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	
func _ready():
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_input = event.relative
	match global_variables.weapon:
		0:
			tazer_crosshair.visible = false 
			tri_form_crosshair.visible = false
		1 : 
			tazer_crosshair.visible = true 
			tri_form_crosshair.visible = false
		2 : 
			tazer_crosshair.visible = false
			tri_form_crosshair.visible = true


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	fuel.value = floor(int((FUEL)))
	percentage.text = str(floor(int(FUEL)),"%")
	pass


func _physics_process(delta):
	
	GUN_CAMERA.global_transform = CAMERA.global_transform
	GUN_CAMERA.fov = 90
	
	global_variables.is_player_sliding = is_sliding
	
	
	# Add the gravity.
	if !is_on_floor():
		velocity.y -= gravity * delta
	if is_on_wall_only():
		velocity.y -= delta
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (NECK.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if FUEL >= 5:
		_dash(direction)
	if FUEL > 0:
		_slide(delta)
	if FUEL >= 15:
		_slam(delta)
	if FUEL >= 0.5:
		_thrust()
	if FUEL < 5:
		is_dashing = false
	if FUEL < 15:
		is_slamming = false
	if FUEL < 0 && !is_slamming:
		is_sliding = false
	
	_jump()
	
	if !is_sliding && !is_dashing:
		if is_on_floor():
			if direction:
				velocity.x = move_toward(velocity.x, direction.x * WALK_SPEED, GROUND_ACCELERATION)
				velocity.z = move_toward(velocity.z, direction.z * WALK_SPEED, GROUND_ACCELERATION)
			else:
				velocity.x = move_toward(velocity.x, 0, GROUND_ACCELERATION/2)
				velocity.z = move_toward(velocity.z, 0, GROUND_ACCELERATION/2)
		else:
			var cur_speed = velocity.dot(direction)
			var capped_speed = min((AIR_SPEED * direction).length(), AIR_CAP)
			var add_speed = capped_speed - cur_speed
			if add_speed > 0:
				var accelerate = AIR_ACCELERATION * AIR_SPEED * delta
				accelerate = min(accelerate, add_speed)
				velocity += accelerate * direction
	
	move_and_slide()
	cam_tilt(input_dir.x, delta)
	pass


func _slide(delta) -> void:
	var inp_dih = Input.get_vector("left", "right", "forward", "backward")
	var slide_direction = (SLIDE_DIRECTION.transform.basis * Vector3(inp_dih.x, 0, inp_dih.y)).normalized()
	
	if Input.is_action_pressed("slide"):
		if is_on_floor() && !is_slamming:
			is_sliding = true
			if slide_direction:
				velocity.x = move_toward(velocity.x, slide_direction.x * SLIDE_MAX_SPEED, SLIDE_ACCELERATION)
				velocity.z = move_toward(velocity.z, slide_direction.z * SLIDE_MAX_SPEED, SLIDE_ACCELERATION)
			else:
				velocity = lerp(velocity, SLIDE_DIRECTION.transform.basis * Vector3(0,0,-SLIDE_MAX_SPEED), SLIDE_ACCELERATION)
		else:
			is_dashing = false
	if !Input.is_action_pressed("slide"):
		is_sliding = false
		SLIDE_DIRECTION.rotation = NECK.rotation
	
	if is_sliding:
		scrath_vfx.emitting = true
		scale = lerp(scale, Vector3(1,0.5,1), delta * 10)
		CAMERA.rotation.z = move_toward(CAMERA.rotation.z, 0.125, delta)
		if Input.is_action_pressed("jump"):
			velocity.y = JUMP_FORCE
	else:
		scrath_vfx.emitting = false
		scale = lerp(scale, Vector3(1,1,1), delta)
		CAMERA.rotation.z = move_toward(CAMERA.rotation.z, 0.0, delta * 20)
	pass


@warning_ignore("unused_parameter")
func _slam(delta) -> void:
	var sparks: GPUParticles3D = $"NECK/VFX/Slam effect/sparks"
	var air: GPUParticles3D = $"NECK/VFX/Slam effect/air"
	if !is_on_floor():
		if Input.is_action_just_pressed("slide"):
			FUEL -= 15
			is_slamming = true
	else:
		if is_on_floor():
			await  get_tree().create_timer(0.07).timeout
			is_slamming = false
		else:
			is_slamming = false
	if is_slamming:
		velocity = Vector3.ZERO
		sparks.emitting = true
		air.emitting = true
		velocity.y -= SLAM_FORCE
	else:
		sparks.emitting =  false
		air.emitting = false
	pass


func _dash(dir) -> void:
	var dust: GPUParticles3D = $"NECK/VFX/Dash effect/dust"
	if is_on_floor():
		DASH_FORCE = 30.0
	else:
		DASH_FORCE = 15.0
	
	if Input.is_action_just_pressed("dash"):
		FUEL -= 5
		is_dashing = true
		await get_tree().create_timer(0.05).timeout
		is_dashing = false
	if is_dashing:
		dust.emitting = true
		velocity.y = 0
		if dir:
			velocity.x += dir.x * DASH_FORCE
			velocity.z += dir.z * DASH_FORCE
		else:
			velocity += NECK.transform.basis * Vector3(0,0,-DASH_FORCE)
	else:
		dust.emitting = false
	pass


func _thrust() -> void:
	if Input.is_action_pressed("thrust"):
		velocity.y = move_toward(velocity.y, MAX_THRUST, THRUST) 
		FUEL -= 0.5
	if Input.is_action_just_released("thrust"):
		velocity.y = move_toward(velocity.y, 0.0, velocity.y/1.5) 
	pass


func _jump() -> void:
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			air_jump_no = 0
			wall_jump_no = 0
			velocity.y = JUMP_FORCE
			if is_slamming || is_dashing:
				air_jump_no = 0
				wall_jump_no = 0
				velocity.y = JUMP_FORCE * 2
		if is_on_wall() && FUEL > 0:
			@warning_ignore("unused_variable")
			var normal = get_wall_normal()
			velocity.y = JUMP_FORCE
		else:
			wall_jump_no = 0
			if !Input.is_action_just_pressed("jump"):
				BUFFER.start()
	if !BUFFER.is_stopped():
		if Input.is_action_pressed("jump"):
			if is_on_floor():
				velocity.y = JUMP_FORCE
				if is_slamming || is_dashing:
					air_jump_no = 0
					wall_jump_no = 0
					velocity.y = JUMP_FORCE * 2
	pass


func cam_tilt(input_x, delta) -> void:
	CAMERA.rotation.z = lerp(CAMERA.rotation.z, -input_x * 0.25,2*delta)
	pass
