extends CharacterBody3D



@export var WALK_SPEED : float = 24.0
@export var GROUND_ACCELERATION : float = 8.0
@export var JUMP_FORCE : float = 24.0
@export var AIR_CAP : float = 1.9
@export var AIR_SPEED : float = 1000.0
@export var AIR_ACCELERATION : float = 1600.0
@export var SLIDE_MAX_SPEED : float = 32.0
@export var SLIDE_ACCELERATION : float = 2.0
@export var DASH_FORCE : float = 50.0

@export var SENSITIVITY : float = 0.5

@onready var CAMERA: Camera3D = $NECK/camera
@onready var NECK: Node3D = $NECK
@onready var SLIDE_DIRECTION: Node3D = $"slide direction"

@onready var slide_vfx: GPUParticles3D = $"slide direction/slide_vfx"
@onready var slam_effect_vfx: GPUParticles3D = $slam_effect_vfx

@onready var slide_sfx: AudioStreamPlayer3D = $slide_sfx

@onready var stair_below_checker: RayCast3D = $NECK/stair_below_checker
@onready var stair_ahead_checker: RayCast3D = $NECK/stair_ahead_checker

var touch_no : float = 0.0
var nrg_conserved : float = 0.0
var wall_jump_no : int = 0

const max_step_height = 1
var snapped_to_stairs_last_frame :bool = false
var last_frame_was_on_floor = -INF

var is_dashing : bool = false
var is_slamming : bool = false
var is_sliding : bool = false

var is_paused : bool
var is_alive : bool = true
var c_gravity : float
var del

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	randomize()

func _process(_delta):
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if is_on_floor():
		nrg_conserved -= 0.3
	else:
		nrg_conserved -= 0.05
	nrg_conserved = clamp(nrg_conserved, 0.0, INF)


func _physics_process(delta):

	if velocity.y < 0:
		gravity = 36.0
	elif velocity.y > 0:
		gravity = 24.0

	if is_on_floor(): last_frame_was_on_floor = Engine.get_physics_frames()

	if is_alive:
		if !is_paused:
			
			global_variables.is_player_sliding = is_sliding
			if !is_on_floor():
				velocity.y -= gravity * delta
			if is_on_wall():
				velocity.y -= delta * gravity / 3
			
			var input_dir = Input.get_vector("left", "right", "forward", "backward")
			var direction = (NECK.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

			_jump(delta)

			if !is_sliding && !is_dashing:
				if is_on_floor() or snapped_to_stairs_last_frame:
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

			_dash(direction, delta)
			_slide(delta)
			#_slam(delta)

	if !_snap_up_to_stairs_check(delta):
		move_and_slide()
		_snap_down_to_stairs_check()


func is_surface_too_steep(normal: Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > floor_max_angle
func _run_body_test_motion(from: Transform3D, motion: Vector3, result = null) -> bool:
	if not result: result = PhysicsTestMotionResult3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(get_rid(), params, result)

func _snap_down_to_stairs_check() -> void:
	var did_snap: bool = false
	var floor_below: bool = stair_below_checker.is_colliding() && !is_surface_too_steep(stair_below_checker.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() - last_frame_was_on_floor == 1
	if not is_on_floor() && velocity.y <= 0 && (was_on_floor_last_frame or snapped_to_stairs_last_frame) && floor_below:
		var body_test_result = PhysicsTestMotionResult3D.new()
		if _run_body_test_motion(global_transform, Vector3(0, -max_step_height, 0), body_test_result):
			var translate_y = body_test_result.get_travel().y
			position.y += translate_y
			apply_floor_snap()
			did_snap = true
	snapped_to_stairs_last_frame = did_snap

func _snap_up_to_stairs_check(delta) -> bool:
	if !is_on_floor() && !snapped_to_stairs_last_frame: return false
	var expected_move_motion = velocity * Vector3(1, 0, 1) * delta
	var step_pos_with_clearence = global_transform.translated(expected_move_motion + Vector3(0, -max_step_height * 2, 0))
	var down_check_result = PhysicsTestMotionResult3D.new()
	if (_run_body_test_motion(step_pos_with_clearence, Vector3(0, -max_step_height * 2, 0), down_check_result)
	&& (down_check_result.get_collider().is_class("StaticBody3D") || down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearence.origin + down_check_result.get_travel()) - global_position).y
		if step_height > max_step_height || step_height <= 0.01 || (down_check_result.get_collision_point() - global_position).y >  max_step_height: return false
		stair_ahead_checker.global_position = down_check_result.get_collision_point() + Vector3(0, max_step_height, 0) + expected_move_motion.normalized * 0.01
		stair_ahead_checker.force_raycast_update()
		if stair_ahead_checker.is_colliding() && !is_surface_too_steep(stair_ahead_checker.get_collision_normal()):
			global_position = step_pos_with_clearence + down_check_result.get_travel()
			apply_floor_snap()
			snapped_to_stairs_last_frame = true
			return true
	return false


var can_slide: bool
func _slide(delta) -> void:
	
	slide_vfx.emitting = is_sliding
	slide_sfx.pitch_scale = randf_range(1, 1.5)
	if is_sliding: 
		if !slide_sfx.playing: slide_sfx.play()
	else:
		slide_sfx.stop()
	
	var slide_direction
	if !is_sliding:
		var inp_dih = Input.get_vector("left", "right", "forward", "backward")
		slide_direction = (SLIDE_DIRECTION.transform.basis * Vector3(inp_dih.x, 0, inp_dih.y)).normalized()
		CAMERA.rotation.z = move_toward(CAMERA.rotation.z, 0.0, delta * 10)
		scale = lerp(scale, Vector3(1, 1, 1), delta * 10)
		SLIDE_DIRECTION.transform.basis = NECK.transform.basis
	else:
		CAMERA.rotation.z = move_toward(CAMERA.rotation.z, deg_to_rad(1.0), delta * 10)
		scale = lerp(scale, Vector3(1, 0.25, 1), delta * 10)
		nrg_conserved = 2
	
	if is_on_floor():
		can_slide = true
	else:
		can_slide = false
		is_sliding = false
	
	if can_slide:
		if Input.is_action_pressed("slide"):
			is_sliding = true
		else:
			is_sliding = false
	
	if is_sliding:
		if slide_direction:
			if ((velocity.length()) - velocity.y) < SLIDE_MAX_SPEED:
				velocity.x += slide_direction.x * SLIDE_ACCELERATION
				velocity.z += slide_direction.z * SLIDE_ACCELERATION
			else:
				velocity = lerp(velocity, Vector3(0, 0, -SLIDE_MAX_SPEED), delta * 10)
		else:
			if ((velocity.length()) - velocity.y) < SLIDE_MAX_SPEED:
				velocity += SLIDE_DIRECTION.transform.basis * Vector3(0, 0, -SLIDE_ACCELERATION)
			else:
				velocity = lerp(velocity, SLIDE_DIRECTION.transform.basis * Vector3(0, 0, -SLIDE_MAX_SPEED), delta * 10)


func _dash(dir, delta) -> void:
	global_variables.is_player_dashing = is_dashing
	
	if Input.is_action_just_pressed("dash"):
		is_dashing = true
		velocity = Vector3.ZERO
		await get_tree().create_timer(0.1).timeout
		is_dashing = false
	if is_dashing:
		nrg_conserved = 5.0
		velocity.y = clamp(velocity.y, 0.0, INF)
		if dir:
			if velocity.length() <= 72:
				velocity.x += dir.x * DASH_FORCE
				velocity.z += dir.z * DASH_FORCE
		else:
			if velocity.length() <= 72:
				velocity += NECK.transform.basis * Vector3(0,0,-DASH_FORCE)
		await get_tree().create_timer(0.15).timeout
		velocity.z = move_toward(velocity.z, 0.0, 75)
		velocity.x = move_toward(velocity.x, 0.0, 75)
	pass


func _jump(_delta) -> void:
	if Input.is_action_pressed("jump"):
		if is_on_floor():
			wall_jump_no = 0
			wall_jump_no = 0
			velocity.y = JUMP_FORCE + nrg_conserved
			if is_dashing:
				wall_jump_no = 0
				velocity.y = JUMP_FORCE
		if is_on_wall_only() && wall_jump_no <= INF:
			var normal = get_wall_normal()
			velocity = normal * JUMP_FORCE
			velocity.y = JUMP_FORCE + nrg_conserved
			wall_jump_no += 1


func explosion_damage(damage: float, knockback: float, origin_position: Vector3) -> void:
	var triggered: bool
	var knockback_dir: Vector3 = (origin_position - global_position).normalized()
	if triggered == false:
		velocity += knockback_dir * knockback
		triggered = true
