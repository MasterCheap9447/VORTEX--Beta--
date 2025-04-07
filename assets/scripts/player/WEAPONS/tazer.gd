extends Node3D


var time : float = 0.0
var start_time : float = 0.0
var end_time : float = 0.0
var equiped : bool

@export var damage: float = 3.0
@export var voltage: float = 3.0

@onready var animation: AnimationPlayer = $model/AnimationPlayer
@onready var ray: RayCast3D = $"ray"
@onready var zap_effect: AudioStreamPlayer3D = $model/tazer_zap_effect
@onready var zap: Sprite3D = $"model/zap"
@onready var zap_emission: OmniLight3D = $model/zap_emission
@onready var model: Node3D = $model
@onready var barrel_position_1: Node3D = $"barrel position 1"


func _process(delta: float) -> void:
	time += delta
	if equiped:
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



func primary_fire() -> void:
	voltage = 3
	if ray.is_colliding():
		var target = ray.get_collider()
		if target != null:
			if target.is_in_group("Enemy"):
				if target.has_method("tazer_hit"):
					target.tazer_hit(damage, voltage)

func alternate_frie() -> void:
	if ray.is_colliding():
		var target = ray.get_collider()
		if target != null:
			if target.is_in_group("Enemy"):
				if target.has_method("tazer_hit"):
					target.tazer_hit(damage, voltage)


func _on_player_change_to_amplifier() -> void:
	equiped = false

func _on_player_change_to_tazer() -> void:
	equiped = true
	
func _on_player_change_to_tri_form() -> void:
	equiped = false
