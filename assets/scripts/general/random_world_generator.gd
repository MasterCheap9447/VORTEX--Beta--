extends MeshInstance3D


var surface_array : Array = []


func _ready() -> void:
	surface_array.resize(Mesh.ARRAY_MAX)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
