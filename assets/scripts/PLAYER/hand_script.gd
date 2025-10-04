extends Node3D




@onready var hand_animation: AnimationPlayer = $model/hand_animation
@onready var parry_area: Area3D = $model/parry_area
@onready var camera: Camera3D = $".."


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("parry"):
		if !hand_animation.is_playing():
			hand_animation.play("parry")
	pass

func _physics_process(delta: float) -> void:
	if hand_animation.is_playing():
		
		for b in parry_area.get_overlapping_bodies():
			if b.is_in_group("Projectile"):
				if b.has_method("parry"):
					b.parry((camera.global_transform.basis * Vector3(0, 0, -1)))
