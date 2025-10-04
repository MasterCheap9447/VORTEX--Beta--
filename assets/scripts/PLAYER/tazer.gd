extends Node3D



@onready var animation: AnimationPlayer = $model/animation
@onready var muzzle_flash: Sprite3D = $tazer_muzzle_flash
@onready var player: CharacterBody3D = $"../../.."
@onready var barrel_pos: Marker3D = $tazer_barrel_pos
@onready var attack_cast: ShapeCast3D = $tazer_attack_cast
@onready var spin_sfx: AudioStreamPlayer3D = $tazer_spin_sfx
@onready var shoot_sfx: AudioStreamPlayer3D = $tazer_shoot_sfx
@onready var crosshair_dot: TextureRect = $"../../../UI/crosshair_dot"
@onready var crosshair_animation: AnimationPlayer = $"../../../UI/tazer_crosshair/tazer_crosshair_animation"
@onready var end_pos: Marker3D = $tazer_end_pos

var instance
var equiped: bool
var equip_anim_done: bool

var wire_trail = load("res://assets/scenes/wire_trail.tscn")


func _ready() -> void:
	equiped = true
	randomize()



func _physics_process(_delta: float) -> void:

	if equiped:

		if !equip_anim_done:
			animation.play("equip")
			await get_tree().create_timer(0.25).timeout
			equip_anim_done = true

		muzzle_flash.rotation.z = deg_to_rad(randf_range(-360, 360))
		spin_sfx.pitch_scale = shoot_sfx.pitch_scale + randf_range(-0.06, 0.06)

		shoot_sfx.pitch_scale = randf_range(1, 1.5)
		if Input.is_action_pressed("primary_fire"):
			if animation.current_animation != "equip":
				if !animation.is_playing():
					animation.play("primary_fire")
					primary_fire()
					crosshair_animation.play("primary_fire")
		
		if Input.is_action_pressed("alt_fire"):
			if !animation.is_playing():
				animation.play("alt_fire_continue")
				crosshair_animation.play("alt_fire_hold")

		if Input.is_action_just_released("alt_fire"):
			animation.stop()
			crosshair_animation.stop()
			animation.play("primary_fire")
			crosshair_animation.play("primary_fire")
			primary_fire()


func primary_fire():
	instance = wire_trail.instantiate()
	instance.position = barrel_pos.global_position
	instance.transform.basis = barrel_pos.global_transform.basis
	player.get_parent().add_child(instance)
	if attack_cast.is_colliding():
		var target = attack_cast.get_collider(0)
		if target.is_in_group("Projectile"):
			if target.has_method("explode"):
				target.explode()
