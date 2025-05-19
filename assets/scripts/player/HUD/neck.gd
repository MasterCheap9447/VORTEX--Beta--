extends Node3D


## RANGED WEAPONS ##
@onready var RANGED_WEAPONS: Node3D = $camera/WEAPONS
@onready var tazer: Node3D = $camera/WEAPONS/tazer
@onready var tri_form: Node3D = $camera/WEAPONS/tri_form

## MELEE WEAPONS ##
@onready var MELEE_WEAPONS: Node3D = $camera/FORCE
@onready var chainsaw_gauntlets: Node3D = $"camera/FORCE/chainsaw gauntlets"

## GLOBAL VARIABLES ##
var weapon_type : bool
var weapon : int
var weapon_count : int

func _ready() -> void:
	weapon = 1
	weapon_type = false
	pass



func _unhandled_input(event: InputEvent) -> void:
	
	# SYNCHRONIZING GLOBAL VARIABLES #
	global_variables.weapon_type = weapon_type
	global_variables.weapon = weapon
	global_variables.weapon_count = weapon_count
	
	
	# WEAPON MANAGEMENT #
	if Input.is_action_just_pressed("weapon type switch"):
		if weapon_type:
			weapon_type = false
		else:
			weapon_type = true
	
	if weapon_type:
		weapon_count = 2
	else:
		weapon_count = 1
	
	if Input.is_action_just_pressed("1"):
		weapon = 1
	if Input.is_action_just_pressed("2"):
		weapon = 2
	if Input.is_action_pressed("scroll up"):
		weapon += 1
	if Input.is_action_pressed("scroll down"):
		weapon -= 1
	
	if weapon > weapon_count:
		weapon = 1
	if weapon < 1:
		weapon = weapon_count


func _process(delta: float) -> void:
	
	## WEAPON EQUIPMENT ##
	if weapon_type:
		chainsaw_gauntlets.unequip()
		if weapon == 1:
			tazer.equip()
			tri_form.unequip()
		if weapon == 2:
			tazer.unequip()
			tri_form.equip()
	else:
		tazer.unequip()
		tri_form.unequip()
		if weapon == 1:
			chainsaw_gauntlets.equip()
	pass
