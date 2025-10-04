extends RigidBody3D


@onready var collider = $collider

@onready var parryable_area: Area3D = $parryable_area
@onready var explodable_area: Area3D = $explodable_area

@onready var mesh: MeshInstance3D = $mesh
@onready var parry_indicator: MeshInstance3D = $parry_indicator

var instance
var light_explosion = load("res://assets/scenes/light_explosion.tscn")

var is_parried: bool
var can_be_parried: bool

func _ready() -> void:
	can_be_parried = true

func _physics_process(_delta):
	
	parry_indicator.visible = can_be_parried
	
	if is_parried == true:
		if explodable_area.has_overlapping_bodies():
			global_variables.is_mine_spawned = false
			explode()


func explode():
	parry_indicator.hide()
	mesh.hide()
	sleeping = true
	instance = light_explosion.instantiate()
	instance.position = global_position
	get_parent().add_child(instance)
	instance.explode()
	global_variables.is_mine_spawned = false
	await get_tree().create_timer(0.5).timeout
	queue_free()


func parry(direction: Vector3):
	if can_be_parried:
		apply_impulse(direction * 10)
		$parry_window.start()
		is_parried = true


func _parry_window_timeout() -> void:
	can_be_parried = false

func _parry_explode_timeout() -> void:
	pass
