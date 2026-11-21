extends AreaButon

@onready var mat: StandardMaterial3D = $MeshInstance3D.get_active_material(0) as StandardMaterial3D

var emission_tween: Tween


func _ready() -> void:
	super._ready()

	if mat == null:
		push_error("Accert: не удалось получить материал MeshInstance3D.")
		return

	# Для свечения необходимо явно включить emission.
	mat.emission_enabled = true
	mat.emission = mat.albedo_color
	mat.emission_energy_multiplier = 0.0


func on() -> void:
	super.on()
	_animate_emission(6.0)


func off() -> void:
	super.off()
	_animate_emission(0.0)


func _animate_emission(target: float) -> void:
	if mat == null:
		return

	if emission_tween and emission_tween.is_running():
		emission_tween.kill()

	emission_tween = create_tween()
	emission_tween.set_trans(Tween.TRANS_QUAD)
	emission_tween.set_ease(Tween.EASE_OUT)
	emission_tween.tween_property(mat, "emission_energy_multiplier", target, 0.2)
