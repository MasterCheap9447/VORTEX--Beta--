extends Node3D


var equiped : bool
var instance

@onready var blast_emission: OmniLight3D = $"blast_emission"
@onready var blast: Sprite3D = $"blast"
@onready var model: Node3D = $export/model
@onready var animation: AnimationPlayer = $export/animation
@onready var rays: Node3D = $rays
@onready var blast_effect: AudioStreamPlayer3D = $tri_form_blast_effect
@onready var player: CharacterBody3D = $"../../../.."

@export var RECOIL : float = 5.0
@export var SPREAD : float = 10

var pellet = load("res://assets/scenes/projectiles/tri_form_pellet.tscn")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("0"):
		equiped = false
	if Input.is_action_just_pressed("1"):
		equiped = false
	if Input.is_action_just_pressed("2"):
		equiped = true
	
	if equiped:
		visible = true
		if Input.is_action_just_pressed("shoot"):
			if !animation.is_playing():
				animation.play("shoot")
				blast_effect.play()
				quad_form_shooting()
	else:
		visible = false

func tri_form_change() -> void:
	equiped = true
func tazer_on() -> void:
	equiped = false


func quad_form_shooting() -> void:
	for r in rays.get_children():
		r.target_position.y = randf_range(SPREAD, -SPREAD)
		r.target_position.x = randf_range(SPREAD, -SPREAD)
		instance = pellet.instantiate()
		instance.position = r.global_position
		instance.transform.basis = r.global_transform.basis
		player.get_parent().add_child(instance)
	pass

func _on_player_change_to_amplifier() -> void:
	equiped = false

func _on_player_change_to_tazer() -> void:
	equiped = false

func _on_player_change_to_tri_form() -> void:
	equiped = true
