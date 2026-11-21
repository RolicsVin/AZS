extends AreaButon

@onready var mat = $MeshInstance3D.get_active_material(0)


func on() -> void:
	super.on()
	mat.emission_energy_multiplier = 6


func off() -> void:
	super.off()
	mat.emission_energy_multiplier = 0
