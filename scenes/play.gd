extends AreaButon

var mat: StandardMaterial3D


func _ready() -> void:
	super._ready()

	# MeshInstance3D отсутствует у некоторых кнопок (например, Play2).
	# Поэтому ищем его безопасно, без ошибки Node not found.
	var mesh_instance := get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh_instance:
		mat = mesh_instance.get_active_material(0) as StandardMaterial3D


func _on_mouse_entered() -> void:
	if is_instance_valid(mat):
		mat.emission_energy_multiplier = 6
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

	super._on_mouse_entered()
	# Используем новый способ смены формы системного курсора.
	


func _on_mouse_exited() -> void:
	if is_instance_valid(mat):
		mat.emission_energy_multiplier = 0
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	super._on_mouse_exited()
