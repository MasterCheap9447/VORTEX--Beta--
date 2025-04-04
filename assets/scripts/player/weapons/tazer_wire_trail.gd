extends MeshInstance3D

@onready var lifetime: Timer = $lifetime

func _ready() -> void:
	lifetime.start()

func _on_lifetime_timeout() -> void:
	queue_free()

func init(pos1: Vector3, pos2: Vector3):
	var draw_mesh = ImmediateMesh.new()
	mesh = draw_mesh
	draw_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material_override)
	draw_mesh.surface_add_vertex(pos1)
	draw_mesh.surface_add_vertex(pos2)
	draw_mesh.surface_end()
