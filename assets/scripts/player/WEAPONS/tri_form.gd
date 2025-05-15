extends Node3D


var equiped : bool
var instance
var done

@onready var model: Node3D = $export/model
@onready var animation: AnimationPlayer = $export/animation
@onready var rays: RayCast3D = $rays
@onready var player: CharacterBody3D = $"../../../.."
@onready var missile_ray: RayCast3D = $"missile ray"
@onready var ideal_ray: RayCast3D = $"ideal ray"

@export var RECOIL : float = 5.0
@export var SPREAD : float = 0.1

var damage : float = 3
var temperature : float = 3

var ammo : int = 3
var time : float = 0.0

var missile = load("res://assets/scenes/projectiles/tri_form_missile.tscn")
var pellet  = load("res://assets/scenes/projectiles/tri_form_pellet.tscn")


func _ready() -> void:
	randomize()
	for r in rays.get_children():
		r.rotation.x = randf_range(-SPREAD, SPREAD)
		r.rotation.y = randf_range(-SPREAD, SPREAD)
		r.rotation.z = randf_range(-SPREAD, SPREAD)
	pass


func _process(delta: float) -> void:
	for r in rays.get_children():
		r.rotation.x = randf_range(-SPREAD, SPREAD)
		r.rotation.y = randf_range(-SPREAD, SPREAD)
		r.rotation.z = randf_range(-SPREAD, SPREAD)
	time += delta
	if ideal_ray.is_colliding():
		missile_ray.target_position = ideal_ray.get_collision_point()
	else:
		missile_ray.target_position = ideal_ray.target_position
	
	if ammo <= 0:
		if !animation.is_playing():
			animation.play("reload")
			ammo = 3
	
	if global_variables.weapon == 2:
		equiped = true
	else:
		equiped = false
	
	var start_time : float
	var end_time : float
	
	if equiped:
		visible = true
		if !done:
			animation.play("equip")
			done = true
		if Input.is_action_just_pressed("shoot") && ammo > 0:
			if !animation.is_playing():
				animation.play("shoot")
				primary_fire()
		if Input.is_action_just_pressed("alt shoot") && ammo >= 3:
			start_time = time
			position = lerp(position, Vector3(0.12, -0.953, 0.7), delta * 2)
		if Input.is_action_just_released("alt shoot"):
			end_time = time
			var time_elapsed : float = end_time - start_time
			if time_elapsed > 2:
				if !animation.is_playing():
					animation.play("shoot")
					alternate_fire()
	else:
		visible = false

func tri_form_change() -> void:
	equiped = true
func tazer_on() -> void:
	equiped = false


func primary_fire() -> void:
	for r in rays.get_children():
		if ideal_ray.is_colliding():
			rays.target_position = (ideal_ray.get_collision_point()).normalized()
		else:
			rays.target_position = (ideal_ray.target_position).normalized()
		instance = pellet.instantiate()
		instance.position = r.global_position
		instance.transform.basis = r.global_transform.basis
		player.get_parent().add_child(instance)
	ammo -= 1
	pass

func alternate_fire() -> void:
	instance = missile.instantiate()
	instance.position = missile_ray.global_position
	instance.transform.basis = missile_ray.global_transform.basis
	player.get_parent().add_child(instance)
	ammo = 0
	pass

func _on_player_change_to_amplifier() -> void:
	equiped = false

func _on_player_change_to_tazer() -> void:
	equiped = false

func _on_player_change_to_tri_form() -> void:
	equiped = true
