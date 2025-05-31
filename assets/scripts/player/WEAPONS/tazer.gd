extends Node3D


var time : float = 0.0
var start_time : float = 0.0
var end_time : float = 0.0
var equiped : bool
var ammo: int
var done : bool
var hit_count : int
var pierce_count : int

var instance
var trail = load("res://assets/scenes/projectiles/bullet_trail.tscn")

@onready var player: CharacterBody3D = $"../../../.."

@export var damage: float = 1.0
@export var voltage: float = 3.0

@onready var animation: AnimationPlayer = $"model/animation"
@onready var model: Node3D = $model

@onready var ray1: RayCast3D = $"ray 1"
@onready var ray2: ShapeCast3D = $"ray 2"
@onready var pierce_area: Area3D = $"pierce area"
@onready var barrel_position_1: Node3D = $"barrel position 1"
@onready var barrel_position_2: Node3D = $"barrel position 2"

@onready var crosshair: TextureRect = $"../../../../UI/tazer crosshair"
@onready var collision_effect: GPUParticles3D = $"tazer collision effect"
@onready var hit_crosshair: TextureRect = $"../../../../UI/hit crosshair"


func _ready() -> void:
	ammo = 8


func _process(delta: float) -> void:
	if ammo <= 0:
		if !animation.is_playing():
			animation.play("reload")
			await get_tree().create_timer(1.0).timeout
			ammo = 8
	
	ammo = clamp(ammo,0,8)
	
	time += delta
	if equiped && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if done == false:
			animation.play("equip")
			done = true
		visible = true
		crosshair.visible = true
		if ammo >= 3:
			if Input.is_action_pressed("alt shoot"):
				if !animation.is_playing():
					animation.play("alt fire")
				start_time = time
			if Input.is_action_just_released("alt shoot"):
				animation.play("primary fire")
				instance = trail.instantiate()
				end_time = time
				voltage = abs(floor(start_time - end_time))
				alternate_frie()
		
	# primary firing
		if Input.is_action_pressed("shoot"):
			voltage = 3
			if !animation.is_playing():
				animation.play("primary fire")
				instance = trail.instantiate()
				primary_fire()
	else:
		done = false
		visible = false
		crosshair.visible = false



func primary_fire() -> void:
	voltage = 3
	if ray1.is_colliding():
		collision_effect.global_position = ray1.get_collision_point()
		collision_effect.emitting = true
		instance.init(barrel_position_1.global_position, ray1.get_collision_point())
		if ray2.is_colliding():
			for i in ray2.get_collision_count():
				var target = ray2.get_collider(i)
				if target.is_in_group("Enemy"):
					if target.has_method("tazer_hit"):
						target.tazer_hit(damage, voltage)
	else:
		instance.init(barrel_position_1.global_position, barrel_position_2.global_position)
		collision_effect.global_position = barrel_position_2.global_position
		collision_effect.emitting = true
	player.get_parent().add_child(instance)
	ammo -= 1

func alternate_frie() -> void:
	global_variables.hit_stop(1)
	for target in pierce_area.get_overlapping_bodies():
		if target.is_in_group("Enemy"):
			if target.has_method("tazer_pierce_hit"):
				target.tazer_pierce_hit(damage, voltage)
				instance.init(barrel_position_1.global_position, target.global_position)
				collision_effect.position = ray1.get_collision_point()
				collision_effect.emitting = true
	
	if ray1.is_colliding():
		pass
	else:
		instance.init(barrel_position_1.global_position, barrel_position_2.global_position)
	player.get_parent().add_child(instance)
	ammo -= 3 
	pass

func equip():
	equiped = true
	pass
func unequip():
	equiped = false
	pass
