extends MeshInstance3D


@onready var life: Timer = $"half life"

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func init(pos1 : Vector3, pos2 : Vector3) -> void:
	var draw = ImmediateMesh.new()
	mesh = draw
	draw.surface_begin(Mesh.PRIMITIVE_LINES, material_override)
	draw.surface_add_vertex(pos1)
	draw.surface_add_vertex(pos2)
	draw.surface_end()
	pass

func _on_half_life_timeout() -> void:
	queue_free()
	pass
