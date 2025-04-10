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


@export_group("GENERAL")
@export var FUEL: float = 200.0
@export var HEALTH: float = 100.0

@export var JUMP_FORCE: float = 300

var gravity = 12
var is_jumping: bool


### GENERAL FUNCTIONING ###
func _process(_delta: float) -> void:
	print(velocity.y)
	
	## Fuel
	FUEL = clamp(FUEL, 0.0, 200.0)
	fuel_bar.value = FUEL
	fuel_percentage.text = str(ceil(FUEL),"%")
	
	## Gun camera and Normal camera Relation
	gun_camera.set_global_transform(camera.get_global_transform())
	gun_camera.fov = 75


### GOOFY AH CODE I AINT TOUCHINIG ###
func _ready() -> void:
	ran.randomize()
	gun_camera.global_transform.basis = camera.global_transform.basis
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


### MOVEMENT IMPLEMENTATION ###
func _physics_process(delta: float) -> void:
	
	## Jumping Control
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity += JUMP_FORCE * jump_direction
	elif is_on_wall_only():
		var wall_normal = (get_wall_normal()).normalized()
		if Input.is_action_just_pressed("jump"):
			if wall_jump_count <= 3:
				velocity = (wall_normal) * JUMP_FORCE / 1.5
				velocity.y += JUMP_FORCE
			else:
				velocity = (wall_normal) * JUMP_FORCE / 3
			#await get_tree().create_timer(1).timeout
			#velocity.y = 0
			#await get_tree().create_timer(0.2).timeout
			#velocity.y -= gravity

	## Directional Variables
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
