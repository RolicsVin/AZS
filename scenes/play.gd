extends AreaButon

@onready var mat = $MeshInstance3D.get_active_material(0)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_mouse_entered():
	mat.emission_energy_multiplier = 6
	super._on_mouse_entered()


func on_mouse_exited():
	mat.emission_energy_multiplier = 0
	super._on_mouse_exited()
