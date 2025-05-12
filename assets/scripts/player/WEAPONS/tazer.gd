extends Node3D


var time : float = 0.0
var start_time : float = 0.0
var end_time : float = 0.0
var equiped : bool
var ammo: int
var done : bool

var instance
var trail = load("res://assets/scenes/projectiles/bullet_trail.tscn")

@onready var player: CharacterBody3D = $"../../../.."

@export var damage: float = 1.0
@export var voltage: float = 3.0

@onready var animation: AnimationPlayer = $model/animation
@onready var zap_effect: AudioStreamPlayer3D = $model/tazer_zap_effect
@onready var zap: Node3D = $model/node/arm/shoulder/bicep/forearm/hand/tazer/zap
@onready var model: Node3D = $model

@onready var ray: RayCast3D = $ray
@onready var pierce_area: Area3D = $"pierce area"
@onready var barrel_position_1: Node3D = $"barrel position 1"
@onready var barrel_position_2: Node3D = $"barrel position 2"

@onready var crosshair: TextureRect = get_parent().get_parent().get_parent().get_parent().get_child(4).get_child(2)
@onready var collision_effect: GPUParticles3D = $"tazer collision effect"


func _ready() -> void:
	ammo = 8


func _process(delta: float) -> void:
	
	if global_variables.weapon == 1:
		equiped = true
	else:
		equiped = false
	
	if ammo <= 0:
		if !animation.is_playing():
			animation.play("reload")
			await get_tree().create_timer(1.0).timeout
			ammo = 8
	
	ammo = clamp(ammo,0,8)
	
	time += delta
	if equiped:
		if done == false:
			animation.play("equip")
			done = true
		visible = true
		crosshair.visible = true
		if ammo >= 3 && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if Input.is_action_pressed("alt shoot"):
				if !animation.is_playing():
					animation.play("alt fire")
				start_time = time
				zap_effect.visible = true
			if Input.is_action_just_released("alt shoot"):
				animation.play("primary fire")
				instance = trail.instantiate()
				end_time = time
				voltage = abs(floor(start_time - end_time))
				zap_effect.play()
				alternate_frie()
				zap_effect.visible = false
	
	# primary firing
		if Input.is_action_pressed("shoot") && Input.get_mouse_mode()==Input.MOUSE_MODE_CAPTURED:
			voltage = 3
			if !animation.is_playing():
				animation.play("primary fire")
				instance = trail.instantiate()
				zap.visible = true
				zap_effect.play()
				primary_fire()
		else:
			zap.visible = false
	else:
		done = false
		visible = false
		crosshair.visible = false



func primary_fire() -> void:
	voltage = 3
	if ray.is_colliding():
		collision_effect.position = ray.get_collision_point()
		collision_effect.emitting = true
		instance.init(barrel_position_1.global_position, ray.get_collision_point())
		var target = ray.get_collider()
		if target != null:
			if target.is_in_group("Enemy"):
				if target.has_method("tazer_hit"):
					target.tazer_hit(damage, voltage)
	else:
		instance.init(barrel_position_1.global_position, barrel_position_2.global_position)
	player.get_parent().add_child(instance)
	ammo -= 1

func alternate_frie() -> void:
	global_variables.hit_stop(1)
	for target in pierce_area.get_overlapping_bodies():
		if target.is_in_group("Enemy"):
			if target.has_method("tazer_hit"):
				target.tazer_hit(damage, voltage * 2)
	if ray.is_colliding():
		instance.init(barrel_position_1.global_position, ray.get_collision_point())
		collision_effect.position = ray.get_collision_point()
		collision_effect.emitting = true
	else:
		instance.init(barrel_position_1.global_position, barrel_position_2.global_position)
	player.get_parent().add_child(instance)
	ammo -= 3
	pass

	pass
