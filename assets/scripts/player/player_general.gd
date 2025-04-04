extends CharacterBody3D



var speed

@onready var tazer_crosshair: TextureRect = $"UI/tazer crosshair"
@onready var quad_form_crosshair: TextureRect = $"UI/quad form crosshair"

@export_group("CAMERA VARIABLES")
@export var SENSITIVITY: float = 0.005
@export var FOV: float = 100

@export_group("MOVEMENT VARIABLES")
@export_subgroup("Ground Movement Variables")
@export var SLIDE_SPEED: float = 24.0
@export var SPEED: float = 16.0
@export var GROUND_ACCELERATION : float = 20.0
@export var GROUND_DECELERATION : float = 14.0
@export var GROUND_FRICTION : float = 8.0
@export var JUMP_FORCE: float = 10.0
@export var DASH_FORCE: float = 30.0
@export var SLAM_FORCE: float = 45.0
var is_sliding: bool = false
@export_subgroup("Aerial Movement Variables")
@export var AIR_CAP: float = 0.85
@export var AIR_ACCELERATION: float = 800.0
@export var AIR_SPEED: float = 500.0
var wall_jump_count: float = 0.0
var air_jump_count: float = 0.0

var stamina: int = 3
@onready var stamina_recharge: Timer = $stamina_recharge

@onready var neck: Node3D = $NECK
@onready var camera: Camera3D = $NECK/camera
@onready var gun_camera: Camera3D = $"UI/viewport/sub viewport/gun_camera"
@onready var health_bar: ProgressBar = $"UI/health bar"
@onready var stamina_visual: AnimatedSprite2D = $"UI/health bar/stamina visual"

var weapon_number: int = 1

@onready var quad_form: Node3D = $NECK/camera/WEAPONS/quad_form
@onready var blast_emission: OmniLight3D = $NECK/camera/WEAPONS/quad_form/blast_emission
@onready var blast: Sprite3D = $NECK/camera/WEAPONS/quad_form/blast
@onready var quad_form_model: Node3D = $NECK/camera/WEAPONS/quad_form/model
@onready var quad_form_animation_player: AnimationPlayer = $NECK/camera/WEAPONS/quad_form/animation_player
@onready var q_barrel_1: RayCast3D = $"NECK/camera/WEAPONS/quad_form/barrel 1"
@onready var q_barrel_2: RayCast3D = $"NECK/camera/WEAPONS/quad_form/barrel 2"
@onready var q_barrel_3: RayCast3D = $"NECK/camera/WEAPONS/quad_form/barrel 3"
@onready var q_barrel_4: RayCast3D = $"NECK/camera/WEAPONS/quad_form/barrel 4"
@onready var quad_form_blast_effect: AudioStreamPlayer3D = $quad_form_blast_effect
@export var QUAD_FORM_RECOIL: float = 5.0
@onready var barrel_position_1: Node3D = $"NECK/camera/WEAPONS/tazer/barrel position 1"

@onready var tazer: Node3D = $NECK/camera/WEAPONS/tazer
@onready var tazer_model: Node3D = $NECK/camera/WEAPONS/tazer/model
@onready var tazer_animation_player: AnimationPlayer = $NECK/camera/WEAPONS/tazer/animation_player
@onready var tazer_ray: RayCast3D = $NECK/camera/WEAPONS/tazer/ray
@onready var tazer_zap_effect: AudioStreamPlayer3D = $tazer_zap_effect
@onready var zap: Sprite3D = $NECK/camera/WEAPONS/tazer/model/zap
@onready var zap_emission: OmniLight3D = $NECK/camera/WEAPONS/tazer/model/zap/zap_emission
@export var tazer_damage: int = 3
@export var tazer_voltage: int = 3

@onready var checker: RayCast3D = $NECK/RAYS/checker
@onready var left_checker: RayCast3D = $"NECK/RAYS/left checker"
@onready var right_checker: RayCast3D = $"NECK/RAYS/right checker"

const HEADBOB_AMPLITUDE = 0.08
const HEADBOB_FREQUENCY = 1.5
var headbob_time: float = 0.0

var wish_direction = Vector3.ZERO
var instance
var time: float = 0.0
var ran = RandomNumberGenerator.new()
var spawn_point = Vector3(0.0, 1.0, 128.0)

var quad_form_pellet = load("res://assets/scenes/projectiles/quad_form_pellet.tscn")
var wire_trail = load("res://assets/scenes/projectiles/tazer_wire_trail.tscn")

@export var HEALTH: int = 100


var tazer_start_time: float = 0.0
var tazer_end_time: float = 0.0


func _process(delta: float) -> void:
	
	
	stamina = clamp(stamina, 0, 3)
	if stamina == 3:
		stamina_visual.frame = 0
	elif stamina == 2:
		stamina_visual.frame = 1
	elif stamina == 1:
		stamina_visual.frame = 2
	else:
		stamina_visual.frame = 3
		
	
	HEALTH = clamp(HEALTH, 0.0, 100.0)
	
	health_bar.value = HEALTH
	
	time += delta
	
	gun_camera.set_global_transform(camera.get_global_transform())
	
	if weapon_number == 1:
		if Input.is_action_pressed("alt shoot"):
			tazer_start_time = time
			tazer_model.rotation.z -= 1
			zap.frame = 1
			zap_emission.visible = true
			velocity.y += 0.5
		if Input.is_action_just_released("alt shoot"):
			tazer_model.rotation.z = 0.0
			tazer_end_time = time
			tazer_voltage = (tazer_start_time - tazer_end_time)
			tazer_zap_effect.play()
			tazer_alt_shoot()
			velocity = get_gravity()
			zap_emission.visible = false
			zap.frame = 0

func _ready() -> void:
	tazer_voltage = 3
	global_position = spawn_point
	var clamp_velo = clamp(velocity.length(), 1.0, 24.0)
	JUMP_FORCE = JUMP_FORCE * clamp_velo
	clamp(JUMP_FORCE, 10.0, 20.0)
	ran.randomize()
	clamp(stamina, 0.0, 3.0)
	tazer_zap_effect.pitch_scale = ran.randf_range(1, 3)
	quad_form_blast_effect.pitch_scale = ran.randf_range(1, 3)
	gun_camera.global_transform.basis = camera.global_transform.basis
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	zap.frame = 0


func clip_velocity(normal:Vector3, overbounce:float, delta:float) -> void:
	var backoff :=  velocity.dot(normal) * overbounce
	if backoff > 0:
		return
	
	var change := normal * backoff
	velocity -= change
	var adjust := velocity.dot(normal)
	if adjust < 0.0:
		velocity -= normal * adjust
	
	if is_on_wall():
		clip_velocity(get_wall_normal(), 1, delta)

func is_surface_too_steep(normal:Vector3) -> bool:
	var max_slope_ang_dot = Vector3(0,1,0).rotated(Vector3(1.0, 0, 0), floor_max_angle).dot(Vector3(0,1,01))
	if normal.dot(Vector3(0,1,0)) < max_slope_ang_dot:
		return true
	return false


func _physics_process(delta: float) -> void:
	
	# respawning
	if HEALTH <= 0:
		global_position = spawn_point
	
	if weapon_number == 1:
		tazer_crosshair.visible = true
		quad_form_crosshair.visible = false
		if Input.is_action_pressed("shoot"):
			if !tazer_animation_player.is_playing():
				tazer_animation_player.play("shoot")
				zap_emission.visible = true
				tazer_zap_effect.play()
				tazer_shooting()
		else:
			zap_emission.visible = false
	elif weapon_number == 2:
		tazer_crosshair.visible = false
		quad_form_crosshair.visible = true
		if Input.is_action_just_pressed("shoot"):
			if !quad_form_animation_player.is_playing():
				quad_form_animation_player.play("shoot")
				blast_emission.visible = true
				quad_form_blast_effect.play()
				quad_form_shooting()
		else:
			blast_emission.visible = false
	
	var velocity_clamped = clamp(velocity.length(), 0.5, SLIDE_SPEED)
	var target_fov = FOV + 1 * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, 12 * delta)
	
	
	var input_direction := Input.get_vector("left", "right", "forward", "backward").normalized()
	wish_direction = (neck.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	if Input.is_action_just_pressed("dash") && stamina>0:
		velocity = neck.transform.basis * Vector3(0, 0, -DASH_FORCE)
		stamina -= 1
	
	if is_on_floor():
		if stamina_recharge.is_stopped():
			stamina_recharge.start()
	
	if is_on_floor():
		if Input.is_action_pressed("slide"):
			speed = SLIDE_SPEED
		else:
			speed = SPEED
		wall_jump_count = 0
		air_jump_count = 0
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
		if stamina > 0:
			if Input.is_action_just_pressed("slide") && stamina>0:
				velocity.y -= SLAM_FORCE
				stamina -= 1
	
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif Input.is_action_pressed("exit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * SENSITIVITY)
			camera.rotate_x(-event.relative.y * SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(120))
	
	if Input.is_action_just_pressed("1"):
		weapon_number = 1
		quad_form.visible = false
		tazer.visible = true
	if Input.is_action_just_pressed("2"):
		weapon_number = 2
		quad_form.visible = true
		tazer.visible = false

## DAMAGE
func damage(poison):
	HEALTH -= poison * 5
	if HEALTH <= 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://assets/scenes/death_screen.tscn")


func handle_air_physics(delta) -> void:
	camera.rotation.z = 0.0
	velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	var cur_speed_in_wish_direction = velocity.dot(wish_direction)
	var capped_speed = min((AIR_SPEED*wish_direction).length(), AIR_CAP)
	var add_speed_till_cap = capped_speed - cur_speed_in_wish_direction
	if add_speed_till_cap > 0:
		var acceleration_speed = AIR_ACCELERATION * AIR_SPEED * delta
		acceleration_speed = min(acceleration_speed, add_speed_till_cap)
		velocity += acceleration_speed * wish_direction
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
func handle_wall_physics(delta) -> void:
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

func _headbob_effect(delta):
	var x = cos(headbob_time * HEADBOB_FREQUENCY/2) * HEADBOB_AMPLITUDE
	var y = sin(headbob_time * HEADBOB_FREQUENCY) * HEADBOB_AMPLITUDE
	headbob_time += delta * velocity.length()
	camera.transform.origin = Vector3(x, y, 0)


## WEAPON FUNCTIONS
func quad_form_shooting() -> void:
	# barrel 1
	instance = quad_form_pellet.instantiate()
	instance.position = q_barrel_1.global_position
	instance.transform.basis = q_barrel_1.global_transform.basis
	get_parent().add_child(instance)
	# barrel 2
	instance = quad_form_pellet.instantiate()
	instance.position = q_barrel_2.global_position
	instance.transform.basis = q_barrel_2.global_transform.basis
	get_parent().add_child(instance)
	# barrel 3
	instance = quad_form_pellet.instantiate()
	instance.position = q_barrel_3.global_position
	instance.transform.basis = q_barrel_3.global_transform.basis
	get_parent().add_child(instance)
	# barrel 4
	instance = quad_form_pellet.instantiate()
	instance.position = q_barrel_4.global_position
	instance.transform.basis = q_barrel_4.global_transform.basis
	get_parent().add_child(instance)

func tazer_shooting() -> void:
	tazer_voltage = 3
	instance = wire_trail.instantiate()
	if tazer_ray.is_colliding():
		var tazer_target = tazer_ray.get_collider()
		if tazer_target != null:
			if tazer_target.is_in_group("Enemy"):
				instance.init(barrel_position_1.global_position, tazer_ray.get_collision_point())
				if tazer_target.has_method("tazer_hit"):
					tazer_target.tazer_hit(0.0, tazer_voltage)
					HEALTH += tazer_damage
func tazer_alt_shoot() -> void:
	instance = wire_trail.instantiate()
	if tazer_ray.is_colliding():
		var tazer_target = tazer_ray.get_collider()
		if tazer_target != null:
			if tazer_target.is_in_group("Enemy"):
				instance.init(barrel_position_1.global_position, tazer_ray.get_collision_point())
				if tazer_target.has_method("tazer_hit"):
					tazer_target.tazer_hit(tazer_damage, tazer_voltage)
					HEALTH += tazer_damage * 2

func _on_stamina_recharge_timeout() -> void:
	if is_on_floor():
		stamina += 1
