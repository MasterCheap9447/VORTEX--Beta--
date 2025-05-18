extends Node3D




var equiped : bool
var done : bool
var rng : int
var can_atk : bool = true

const DAMAGE : float = 40

@onready var player: CharacterBody3D = $"../../../.."
@export var damage: float = 1.0

@onready var animation: AnimationPlayer = $model/animation
@onready var attack_area: Area3D = $"chainsaw attack area"


func _ready() -> void:
	randomize()
	pass


func _physics_process(delta: float) -> void:
	if global_variables.weapon_type == false:
		if global_variables.weapon == 1:
			equiped = true
		else:
			equiped = false
	else:
		equiped = false
	
	if equiped && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		$idle.play()
		if done == false:
			animation.play("equip")
			done = true
		visible = true
	# primary firing
		if Input.is_action_just_pressed("shoot") && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED && can_atk:
			can_atk = false
			$rev.pitch_scale = randf_range(1, 2)
			if !animation.is_playing():
				rng = randi_range(1, 3)
				match rng:
					1: animation.play("finisher 1")
					2: animation.play("finisher 2")
					3: animation.play("finisher 3")
				punch()
				$cooldown.start()
	else:
		$idle.stop()
		done = false
		visible = false
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
