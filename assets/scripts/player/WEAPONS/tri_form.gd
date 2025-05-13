extends Node3D


var equiped : bool
var instance
var done

@onready var blast: Sprite3D = $"export/model/arm 2/shoulder/bicep/forearm/hand/tri form/blast"
@onready var model: Node3D = $export/model
@onready var animation: AnimationPlayer = $export/animation
@onready var rays: Node3D = $rays
@onready var blast_effect: AudioStreamPlayer3D = $tri_form_blast_effect
@onready var player: CharacterBody3D = $"../../../.."
@onready var missile_ray: RayCast3D = $"missile ray"
@onready var ideal_ray: RayCast3D = $"ideal ray"

@export var RECOIL : float = 5.0
@export var SPREAD : float = 10

var damage : float = 3
var temperature : float = 3

var ammo : int = 3
var time : float = 0.0

var missile = load("res://assets/scenes/projectiles/tri_form_missile.tscn")


func _ready() -> void:
	randomize()
	for r in rays.get_children():
		r.target_position.y = randf_range(SPREAD, -SPREAD)
		r.target_position.x = randf_range(SPREAD, -SPREAD)
	pass


func _process(delta: float) -> void:
	time += delta
	
	if ideal_ray.is_colliding():
		var point = ideal_ray.get_collision_point()
		missile_ray.target_position = point
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
				blast_effect.play()
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
					blast_effect.play()
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
			var point = ideal_ray.get_collision_point()
			r.target_position = point
		r.target_position.y = randf_range(SPREAD, -SPREAD)
		r.target_position.x = randf_range(SPREAD, -SPREAD)
		if r.is_colliding():
			var target = r.get_collider()
			if target != null:
				if target.is_in_group("Enemy"):
					if target.has_method("tri_form_hit"):
						target.tri_form_hit(damage, temperature)
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
