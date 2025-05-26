extends CharacterBody3D



@export var WALK_SPEED : float = 16.0
@export var GROUND_ACCELERATION : float = 4.0
@export var JUMP_FORCE : float = 12.0
@export var AIR_CAP : float = 0.85
@export var AIR_SPEED : float = 500.0
@export var AIR_ACCELERATION : float = 800.0
@export var SLAM_FORCE : float = 100.0
@export var SLIDE_MAX_SPEED : float = 24.0
@export var SLIDE_ACCELERATION : float = 1.0
@export var DASH_FORCE : float = 24.0
@export var THRUST : float = 5.0
@export var MAX_THRUST : float = 50.0

@export var FUEL : float = 200.0
@export var HEALTH : float = 400.0
@export var STYLE : float = 0.0

@export var SENSITIVITY : float = 0.5
@export var WEAPON_SWAY_AMMOUNT : float = 0.01
@export var WEAPON_ROTATION_AMMOUNT : float = 0.05

@onready var CAMERA: Camera3D = $NECK/camera
@onready var NECK: Node3D = $NECK
@onready var SLIDE_DIRECTION: Node3D = $"slide direction"
@onready var BUFFER: Timer = $buffer
@onready var GUN_CAMERA: Camera3D = $"UI/view container/SubViewport/gun camera"
@onready var WEAPONS: Node3D = $NECK/camera/WEAPONS
@onready var FORCE: Node3D = $NECK/camera/FORCE
@onready var scrath_vfx: GPUParticles3D = $"slide direction/Scraps/Scrath VFX"
@onready var slam_area: Area3D = $"NECK/SLAM/slam area"

@onready var tazer_model: Node3D = $NECK/camera/WEAPONS/tazer/model
@onready var bi_form_model: Node3D = $NECK/camera/WEAPONS/tri_form/model
@onready var chainsaw_gauntlets_model: Node3D = $"NECK/camera/FORCE/chainsaw gauntlets/model"

@onready var fuel: TextureProgressBar = $UI/Container/Control/fuel
@onready var f_percentage: RichTextLabel = $UI/Container/Control/fuel/percentage
@onready var health: TextureProgressBar = $UI/Container/Control/health
@onready var h_percentage: RichTextLabel = $UI/Container/Control/health/percentage
@onready var speed: RichTextLabel = $UI/Container/Control/speedometer/speed
@onready var style: TextureProgressBar = $UI/Container/Control/style/bar


@onready var pause_menu: Control = $"UI/pause menu"
@onready var death_screen: Control = $"UI/death screen"
@onready var blue_screen: Sprite2D = $"UI/death screen/blue screen"
@onready var black_screen: Sprite2D = $"UI/death screen/black screen"

@onready var jump_sfx: AudioStreamPlayer3D = $"jump SFX"
@onready var walk_sfx: AudioStreamPlayer3D = $"walk SFX"
@onready var thrust_sfx: AudioStreamPlayer3D = $"thrust SFX"
@onready var dash_sfx: AudioStreamPlayer3D = $"dash SFX"

var touch_no : float = 0.0
var nrg_conserved : float = 0.0
var air_jump_no : int = 0
var wall_jump_no : int = 0

var is_dashing : bool = false
var is_slamming : bool = false
var is_sliding : bool = false
var is_flying : bool = false
var fuel_enabled : bool = true

var weapon_sway : float = 5
var weapon_rotate : float = 0.005
var mouse_input : Vector2
var is_paused : bool
var is_alive : bool = true
var locational_multiplier : float = 1.0
var state_multiplier : float = 1.0
var d : float = 0.0
var c_gravity : float

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _input(event: InputEvent) -> void:
	if is_alive:
		if !is_paused:
			if event is InputEventMouseMotion:
				mouse_input = event.relative
	pass


func _process(delta: float) -> void:
	audio()
	d = delta
	GUN_CAMERA.global_transform = CAMERA.global_transform
	global_variables.is_paused = is_paused
	global_variables.is_player_alive = is_alive
	
	if is_alive:
		if pause_menu.visible == true:
			is_paused = true
		else:
			is_paused = false
	
		if !is_paused:
			audio()
			speed.text = (str(snapped(velocity.length(), 0.1)) + " m/s" )
			FUEL = clamp(FUEL, 0.0, 200.0)
			HEALTH = clamp(HEALTH, 0.0, 400.0)
			fuel.value = floor(int(FUEL))
			f_percentage.text = (str(floor(int(FUEL))) + " %")
			health.value = floor(int(HEALTH))
			h_percentage.text = (str(floor(int(HEALTH))) + " %")
			_style(delta)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if Input.is_action_just_pressed("exit"):
			get_tree().change_scene_to_file("res://assets/scenes/GENERAL/menu.tscn")
	pass


func _physics_process(delta):
	if is_paused:
		Engine.time_scale = 0
	else:
		Engine.time_scale = 1
	
	if is_alive:
		if !is_paused:
			death()
			
			GUN_CAMERA.global_transform = CAMERA.global_transform
			GUN_CAMERA.fov = 90
			
			global_variables.is_player_sliding = is_sliding
			if !is_on_floor():
				velocity.y -= gravity * delta
			if is_on_wall():
				velocity.y -= delta * gravity / 3
			
			var input_dir = Input.get_vector("left", "right", "forward", "backward")
			var direction = (NECK.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			
			JUICE(input_dir.x, delta)
			
			_jump(delta)
			
			if !is_sliding && !is_dashing:
				if is_on_floor():
					if direction:
						velocity.x = move_toward(velocity.x, direction.x * WALK_SPEED, GROUND_ACCELERATION)
						velocity.z = move_toward(velocity.z, direction.z * WALK_SPEED, GROUND_ACCELERATION)
					else:
						velocity.x = move_toward(velocity.x, 0, GROUND_ACCELERATION/2)
						velocity.z = move_toward(velocity.z, 0, GROUND_ACCELERATION/2)
				else:
					nrg_conserved = nrg_conserved / 20
					nrg_conserved += abs(velocity.y / 10) + velocity.length() / 50
					var cur_speed = velocity.dot(direction)
					var capped_speed = min((AIR_SPEED * direction).length(), AIR_CAP)
					var add_speed = capped_speed - cur_speed
					if add_speed > 0:
						var accelerate = AIR_ACCELERATION * AIR_SPEED * delta
						accelerate = min(accelerate, add_speed)
						velocity += accelerate * direction
			
			if fuel_enabled:
				if FUEL >= 5:
					_dash(direction)
				if FUEL > 0:
					_slide(delta)
				if FUEL >= 15:
					_slam(delta)
				if FUEL >= 0.5:
					_thrust(delta)
				if FUEL < 5:
					is_dashing = false
				if FUEL < 15:
					is_slamming = false
				if FUEL < 0 && !is_slamming:
					is_sliding = false
				if FUEL == 0:
					is_dashing = false
					is_slamming = false
					is_sliding = false
			
	
	move_and_slide()
	pass


func _slide(delta) -> void:
	var slide_direction
	if !is_sliding:
		var inp_dih = Input.get_vector("left", "right", "forward", "backward")
		slide_direction = (SLIDE_DIRECTION.transform.basis * Vector3(inp_dih.x, 0, inp_dih.y)).normalized()
	
	if Input.is_action_pressed("slide"):
		if is_on_floor() && !is_slamming:
			is_sliding = true
			var slide_speed : float = 0.0
			if slide_direction:
				if slide_speed < SLIDE_MAX_SPEED:
					slide_speed += SLIDE_ACCELERATION
				velocity.x = slide_direction.x * slide_speed
				velocity.z = slide_direction.z * slide_speed
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
		CAMERA.rotation.z = move_toward(CAMERA.rotation.z, 0.0, delta * 10)
		
	if !is_on_floor():
		scrath_vfx.emitting = false
	pass

func _slam(_delta) -> void:
	var sparks: GPUParticles3D = $"NECK/VFX/Slam effect/sparks"
	var air: GPUParticles3D = $"NECK/VFX/Slam effect/air"
	var slam_force : bool
	var power_slam : bool
	
	if !is_on_floor():
		if Input.is_action_just_pressed("slide"):
			is_slamming = true
			await get_tree().create_timer(0.1).timeout
			if Input.is_action_pressed("slide"):
				power_slam = true
			else:
				power_slam = false
		if Input.is_action_just_released("slide"):
			power_slam = false
			is_slamming = false
			slam_force = false
	else:
		is_slamming = false
		slam_force = false
	
	if is_slamming:
		sparks.emitting = true
		air.emitting = true
		if power_slam:
			velocity = Vector3.ZERO
			velocity.y = -SLAM_FORCE
		else:
			velocity.y = -SLAM_FORCE
	else:
		sparks.emitting = false
		air.emitting = false
	
	pass

func _dash(dir) -> void:
	var dust: GPUParticles3D = $"NECK/VFX/Dash effect/dust"
	
	if Input.is_action_just_pressed("dash"):
		FUEL -= 5
		is_dashing = true
		await get_tree().create_timer(0.05).timeout
		is_dashing = false
	if is_dashing:
		dust.emitting = true
		velocity.y = 0
		if dir:
			if velocity.length() <= 72:
				velocity.x += dir.x * DASH_FORCE
				velocity.z += dir.z * DASH_FORCE
		else:
			if velocity.length() <= 72:
				velocity += NECK.transform.basis * Vector3(0,0,-DASH_FORCE)
		await get_tree().create_timer(0.3).timeout
		velocity.z = 0
		velocity.x = 0
	else:
		dust.emitting = false
	pass

func _thrust(delta) -> void:
	if Input.is_action_pressed("thrust"):
		is_flying = true
	else:
		is_flying = false
	
	if is_flying:
		var inp_d = Input.get_vector("left", "right", "forward", "backward")
		var d = (NECK.transform.basis * CAMERA.transform.basis * Vector3(inp_d.x, 0, inp_d.y)).normalized()
		FUEL -= 1
		if d:
			velocity = d * move_toward(velocity.length(), MAX_THRUST, THRUST)
		else:
			velocity = NECK.transform.basis * CAMERA.transform.basis * Vector3(0, 0, -move_toward(velocity.length(), MAX_THRUST, THRUST))

func _jump(delta) -> void:
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			wall_jump_no = 0
			air_jump_no = 0
			wall_jump_no = 0
			velocity.y = JUMP_FORCE + nrg_conserved
			if is_slamming or is_dashing:
				air_jump_no = 0
				wall_jump_no = 0
				velocity.y = JUMP_FORCE * 10 + nrg_conserved
		if is_on_wall_only() && FUEL > 0 && wall_jump_no <= 3:
			var normal = get_wall_normal()
			velocity = normal * JUMP_FORCE
			velocity.y = JUMP_FORCE + nrg_conserved
			wall_jump_no += 1
			if !Input.is_action_just_pressed("jump"):
				BUFFER.start()
	if !BUFFER.is_stopped():
		if Input.is_action_pressed("jump"):
			if is_on_floor():
				velocity.y = JUMP_FORCE + nrg_conserved
				if is_slamming or is_dashing:
					air_jump_no = 0
					velocity.y = JUMP_FORCE * 10 + nrg_conserved
	pass


func exp_damage(magnitude, pos : Vector3) -> void:
	HEALTH -= magnitude
	var dir = (pos - global_position).normalized()
	velocity += dir * magnitude
	$"hurt stop".start()
	camera_shake(0.1, 0.2, d)
	pass

func nrml_damage(magnitude) -> void:
	HEALTH -= magnitude
	camera_shake(0.1,0.2,d)
	$"hurt stop".start()
	pass

func disable_FUEL() -> void:
	fuel_enabled = false
	pass
func enable_FUEL() -> void:
	fuel_enabled = true
	pass

func heal(magnitude) -> void:
	HEALTH += magnitude
	pass  


func JUICE(input_x, delta) -> void:
	CAMERA.rotation.z = lerp(CAMERA.rotation.z, -input_x * 0.25, 2 * delta)
	pass

func camera_shake(magnitude, amplitude, delta):
	var rng
	rng = RandomNumberGenerator.new()
	rng = randf_range(-magnitude, magnitude)
	CAMERA.rotation.z = lerp(CAMERA.rotation.z, rad_to_deg(rng), delta * amplitude)
	CAMERA.rotation.x = lerp(CAMERA.rotation.x, rad_to_deg(rng), delta * amplitude)
	CAMERA.rotation.y = lerp(CAMERA.rotation.y, rad_to_deg(rng), delta * amplitude)
	pass


func death() -> void:
	if HEALTH <= 0:
		death_screen.show()
		is_alive = false
	else:
		death_screen.hide()
		is_alive = true
	pass


func audio() -> void:
	pass


func _style(delta) -> void:
	global_variables.STYLE -= 0.1
	
	global_variables.STYLE_MULTIPLIER = clamp(global_variables.STYLE_MULTIPLIER, 0.0, 4.5)
	STYLE = clamp(STYLE, 0.0, 100.0)
	global_variables.STYLE = clamp(global_variables.STYLE, 0.0, 100.0)
	
	STYLE = global_variables.STYLE
	global_variables.STYLE_MULTIPLIER = locational_multiplier * state_multiplier
	if is_on_floor():
		locational_multiplier = 1
	else:
		locational_multiplier = 1.5
	
	if is_sliding:
		state_multiplier = 3.0
	if is_dashing:
		state_multiplier = 2.5
	if is_slamming:
		state_multiplier = 1.5
	
	style.value = STYLE
	pass


func _on_hurt_stop_timeout() -> void:
	$"UI/hurt flash".hide()
	Engine.time_scale = 1
	pass
