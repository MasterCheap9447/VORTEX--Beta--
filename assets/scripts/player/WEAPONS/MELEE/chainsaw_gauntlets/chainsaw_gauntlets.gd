extends Node3D



var equiped : bool
var done : bool
var rng : int
var can_atk : bool = true

@onready var player: CharacterBody3D = $"../../../.."
@export var DAMAGE: float = 40.0

@onready var animation: AnimationPlayer = $model/animation
@onready var attack_area: Area3D = $"chainsaw attack area"
@onready var rev: AudioStreamPlayer3D = $rev
@onready var idle: AudioStreamPlayer3D = $idle
@onready var cooldown: Timer = $cooldown

func _ready() -> void:
	randomize()
	pass


func _physics_process(delta: float) -> void:
	if equiped:
		visible = true
		idle.play()
		if done == false:
			animation.play("equip")
			done = true
	# primary firing
		if Input.is_action_just_pressed("shoot") && can_atk:
			rev.pitch_scale = randf_range(1, 1.2)
			if !animation.is_playing():
				rng = randi_range(1, 3)
				match rng:
					1: animation.play("finisher 1")
					2: animation.play("finisher 2")
					3: animation.play("finisher 3")
				can_atk = false
				punch()
				cooldown.start()
		
		if !cooldown.is_stopped():
			idle.volume_db = -25.0
		else:
			idle.volume_db = 0.0
	else:
		done = false
		visible = false
		idle.stop()
	pass


func punch() -> void:
	for target in attack_area.get_overlapping_bodies():
		if target.is_in_group("Enemy"):
			if target.has_method("chainsaw_hit"):
				target.chainsaw_hit(DAMAGE)
				can_atk = false
	pass


func _on_cooldown_timeout() -> void:
	can_atk = true
	pass


func equip():
	equiped = true
	pass
func unequip():
	equiped = false
	pass
