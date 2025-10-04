@tool
extends Node3D


## PARAMETERS ##
@export_category("PARAMETERS")

@export var start_unlocked: bool = true
@export_range(0.5, 2, 0.5) var speed: float = 5
@export var width_height_ratio: Vector2 = Vector2(1, 4)
@export_range(2, 6, 1) var size_constant: float = 3
@export var hook_access: bool = false
@export var hook_peremenant_open: bool = false
@export var id_card_lock: bool = false
@export var hook_point: Node3D
@export var ID_card: Node3D
@export var player: CharacterBody3D

@onready var model: CSGBox3D = $model
@onready var player_detection_area: Area3D = $player_detection_area
@onready var animation: AnimationPlayer = $animation



var door_unlocked: bool
var id_unlocked: bool
var hook_accessed: bool
var hook_being_accessed: bool
var target_position: Vector3


func _ready() -> void:

	if start_unlocked:
		door_unlocked = true


var trigger: bool
var can_close: bool

func _physics_process(_delta: float) -> void:
	pass

func open():
	animation.play("open")
func close():
	animation.play("close")

func _on_player_enter_detection_area(body: CharacterBody3D) -> void:
	if body.is_in_group("Player"):
		open()
func _on_player_exit_detection_area(body: CharacterBody3D) -> void:
	if body.is_in_group("Player"):
		close()
