extends Node3D


var equiped : bool
var instance

@onready var blast_emission: OmniLight3D = $"blast_emission"
@onready var blast: Sprite3D = $"blast"
@onready var model: Node3D = $"model"
@onready var animation_player: AnimationPlayer = $"animation_player"
@onready var barrel_1: RayCast3D = $"barrel 1"
@onready var barrel_2: RayCast3D = $"barrel 2"
@onready var barrel_3: RayCast3D = $"barrel 3"
@onready var barrel_4: RayCast3D = $"barrel 4"
@onready var blast_effect: AudioStreamPlayer3D = $tri_form_blast_effect
@export var RECOIL: float = 5.0

var pellet = load("res://assets/scenes/projectiles/quad_form_pellet.tscn")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("0"):
		equiped = false
	if Input.is_action_just_pressed("1"):
		equiped = false
	if Input.is_action_just_pressed("2"):
		equiped = true
	
	if equiped:
		if Input.is_action_just_pressed("shoot"):
			if !animation_player.is_playing():
				animation_player.play("shoot")
				blast_emission.visible = true
				blast_effect.play()
				quad_form_shooting()
			else:
				blast_emission.visible = false


func tri_form_change() -> void:
	equiped = true
func tazer_on() -> void:
	equiped = false


func quad_form_shooting() -> void:
	# barrel 1
	instance = pellet.instantiate()
	instance.position = barrel_1.global_position
	instance.transform.basis = barrel_1.global_transform.basis
	get_parent().add_child(instance)
	# barrel 2
	instance = pellet.instantiate()
	instance.position = barrel_2.global_position
	instance.transform.basis = barrel_2.global_transform.basis
	get_parent().add_child(instance)
	# barrel 3
	instance = pellet.instantiate()
	instance.position = barrel_3.global_position
	instance.transform.basis = barrel_3.global_transform.basis
	get_parent().add_child(instance)
	# barrel 4
	instance = pellet.instantiate()
	instance.position = barrel_4.global_position
	instance.transform.basis = barrel_4.global_transform.basis
	get_parent().add_child(instance)

func _on_player_change_to_amplifier() -> void:
	equiped = false

func _on_player_change_to_tazer() -> void:
	equiped = false

func _on_player_change_to_tri_form() -> void:
	equiped = true
