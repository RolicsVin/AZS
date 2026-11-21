extends Area3D

signal pressed

var inarea: bool = false

@onready var mat = $MeshInstance3D.get_active_material(0)


func _process(_delta: float) -> void:
	if inarea and Input.is_action_just_pressed("left_mouse"):
		pressed.emit()


func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	inarea = true
	mat.emission_energy_multiplier = 6

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	inarea = false
	mat.emission_energy_multiplier = 0
