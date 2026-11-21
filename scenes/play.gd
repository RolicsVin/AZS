extends AreaButon

@onready var mat = $MeshInstance3D.get_active_material(0)


func _ready() -> void:
	super._ready()


func _on_mouse_entered() -> void:
	mat.emission_energy_multiplier = 6
	super._on_mouse_entered()


func _on_mouse_exited() -> void:
	mat.emission_energy_multiplier = 0
	super._on_mouse_exited()
