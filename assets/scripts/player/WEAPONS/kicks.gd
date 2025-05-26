extends Node3D



@onready var animation: AnimationPlayer = $mesh/animation
@onready var player: CharacterBody3D = $"../../.."
@onready var hit_area: Area3D = $"hit area"
@onready var camera: Camera3D = $".."
@onready var mesh: Node3D = $mesh

const PUSH = 16

var is_used : bool


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	
	if Input.is_action_pressed("kick"):
		if is_used:
			animation.play("kick charge")
			is_used = false
	
	if Input.is_action_just_released("kick"):
		animation.play("kick release")
		is_used = true
		for target in hit_area.get_overlapping_bodies():
			if target.is_in_group("Enemy"):
				target.position += target.transform.basis * Vector3(0, 0, -PUSH)
				target.HEALTH -= PUSH
			if target.is_in_group("Projectile"):
				target.position += target.transform.basis * Vector3(0, 0, -PUSH)
			else:
				if !target.is_in_group("Player"):
					var clamped_vel = clamp(player.velocity.length(), 1.0, 3.0)
					player.velocity = camera.transform.basis * Vector3(0, 0, PUSH * clamped_vel)
	
	pass
