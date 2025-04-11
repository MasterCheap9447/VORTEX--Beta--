extends Node3D


var time : float = 0.0
var start_time : float = 0.0
var end_time : float = 0.0
var equiped : bool
var ammo: int
var done : bool

@export var damage: float = 3.0
@export var voltage: float = 3.0

@onready var animation: AnimationPlayer = $model/animation
@onready var ray: RayCast3D = $ray
@onready var zap_effect: AudioStreamPlayer3D = $model/tazer_zap_effect
#@onready var zap: Sprite3D = $"model/zap"
@onready var zap_emission: OmniLight3D = $model/zap_emission
@onready var model: Node3D = $model
@onready var barrel_position_1: Node3D = $"barrel position 1"
@onready var crosshair: TextureRect = get_parent().get_parent().get_parent().get_parent().get_child(4).get_child(2)



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
		if ammo >= 3:
			if Input.is_action_pressed("alt shoot"):
				if !animation.is_playing():
					animation.play("alt fire")
				start_time = time
				#zap.frame = 1
				zap_emission.visible = true
			if Input.is_action_just_released("alt shoot"):
				animation.play("primary fire")
				end_time = time
				voltage = start_time - end_time
				zap_effect.play()
				alternate_frie()
				zap_emission.visible = false
				#zap.frame = 0
	
	# primary firing
		if Input.is_action_pressed("shoot"):
			if !animation.is_playing():
				animation.play("primary fire")
				zap_emission.visible = true
				zap_effect.play()
				primary_fire()
		else:
			zap_emission.visible = false
	else:
		done = false
		visible = false
		crosshair.visible = false



func primary_fire() -> void:
	voltage = 3
	if ray.is_colliding():
		var target = ray.get_collider()
		if target != null:
			if target.is_in_group("Enemy"):
				if target.has_method("tazer_hit"):
					target.tazer_hit(damage, voltage)
		ammo -= 1

func alternate_frie() -> void:
	if ray.is_colliding():
		var target = ray.get_collider()
		if target != null:
			if target.is_in_group("Enemy"):
				if target.has_method("tazer_hit"):
					target.tazer_hit(damage, voltage)
	ammo -= 3
