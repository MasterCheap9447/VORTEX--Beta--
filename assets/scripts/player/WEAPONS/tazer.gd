extends Node3D


var time : float = 0.0
var start_time : float = 0.0
var end_time : float = 0.0
var equiped : bool

@export var damage: float = 3.0
@export var voltage: float = 3.0

@onready var model: Node3D = $"model"
@onready var animation_player: AnimationPlayer = $"animation_player"
@onready var ray: RayCast3D = $"ray"
@onready var zap_effect: AudioStreamPlayer3D = $"tazer_zap_effect"
@onready var zap: Sprite3D = $"model/zap"
@onready var zap_emission: OmniLight3D = $"model/zap/zap_emission"


func _process(delta: float) -> void:
	time += delta
	if equiped:
		if Input.is_action_pressed("alt shoot"):
			start_time = time
			model.rotation.z -= 1
			zap.frame = 1
			zap_emission.visible = true
		if Input.is_action_just_released("alt shoot"):
			model.rotation.z = 0.0
			end_time = time
			voltage = start_time - end_time
			zap_effect.play()
			alternate_frie()
			zap_emission.visible = false
			zap.frame = 0
	# primary firing
		if Input.is_action_pressed("shoot"):
			if !animation_player.is_playing():
				animation_player.play("shoot")
				zap_emission.visible = true
				zap_effect.play()
				primary_fire()
		else:
			zap_emission.visible = false


func tazer_weapon() -> void:
	equiped = true
func tri_form_on() -> void:
	equiped = false

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
