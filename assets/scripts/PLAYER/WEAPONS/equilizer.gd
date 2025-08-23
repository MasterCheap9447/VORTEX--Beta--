extends Node3D


var equiped : bool
var instance_1
var instance_2
var done

@onready var animation: AnimationPlayer = $model/animation
@onready var hit_ray: ShapeCast3D = $hit_ray
@onready var target_ray: RayCast3D = $target_ray
@onready var r_barrel_origin: Node3D = $r_barrel_origin
@onready var l_barrel_origin: Node3D = $l_barrel_origin
@onready var barrel_end: Node3D = $barrel_end
@onready var player: CharacterBody3D = $"../../../.."


var ammo : int = 80
var damage: int = 1
var trail = load("res://assets/scenes/projectiles/nail_trail.tscn")

func _ready() -> void:
	randomize()
	pass


func _process(delta: float) -> void:
	
	if equiped && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		visible = true
		if !done:
			animation.play("equip")
			done = true
		
		if ammo <= 0:
			if !animation.is_playing():
				animation.play("reload")
				ammo = 80
		if Input.is_action_pressed("shoot") && ammo > 0:
			if !animation.is_playing():
				animation.play("primary fire")
				instance_1 = trail.instantiate()
				instance_2 = trail.instantiate()
				player.camera_shake(0.1, 0.05, delta)
				primary_fire()
				primary_fire()
		if Input.is_action_just_pressed("alt shoot") && ammo >= 3:
			if !animation.is_playing():
				animation.play("alt fire")
				if ammo >= 30:
					alternate_fire()
	else:
		done = false
		visible = false

func tri_form_change() -> void:
	equiped = true
func tazer_on() -> void:
	equiped = false


func primary_fire() -> void:
	if target_ray.is_colliding():
		var target = target_ray.get_collider()
		if target.is_in_group("Enemy"):
			if target.has_method("equilizer_hit"):
				target.equilizer_hit(damage)
	
	var r = randf_range(-1, 1)
	if target_ray.is_colliding():
		instance_1.init(r_barrel_origin.global_position, target_ray.get_collision_point() + Vector3(r,r,0))
		instance_2.init(l_barrel_origin.global_position, target_ray.get_collision_point() + Vector3(r,r,0))
	else:
		instance_1.init(r_barrel_origin.global_position, barrel_end.global_position + Vector3(r,r,0))
		instance_2.init(l_barrel_origin.global_position, barrel_end.global_position + Vector3(r,r,0))
	player.get_parent().add_child(instance_1)
	player.get_parent().add_child(instance_2)
	ammo -= 1
	pass

func alternate_fire() -> void:
	pass


func equip():
	equiped = true
	pass
func unequip():
	equiped = false
	pass
