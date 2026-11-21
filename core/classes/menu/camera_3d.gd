extends Camera3D

@export_category("Position Movement")
@export var position_mouse_sensitivity: float = 0.001
@export var position_mouse_speed: float = 3.0

@export_category("Movement Limits")
@export var x_limit: float = 0.1
@export var z_limit: float = 0.1

@onready var button_manager = $"../Buttons"

var mouse_offset_x: float = 0.0
var mouse_offset_z: float = 0.0

var start_position: Vector3


func _ready() -> void:
	start_position = global_position


func _input(event: InputEvent) -> void:
	if not button_manager.camera_enabled:
		return

	if event is InputEventMouseMotion:
		mouse_offset_x -= event.relative.y * position_mouse_sensitivity
		mouse_offset_z += event.relative.x * position_mouse_sensitivity

		mouse_offset_x = clampf(mouse_offset_x, -x_limit, x_limit)
		mouse_offset_z = clampf(mouse_offset_z, -z_limit, z_limit)


func _process(delta: float) -> void:
	var target_position := Vector3(
		start_position.x + mouse_offset_x,
		start_position.y,
		start_position.z + mouse_offset_z
	)

	global_position = global_position.lerp(
		target_position,
		clampf(position_mouse_speed * delta, 0.0, 1.0)
	)

	global_position.x = clampf(
		global_position.x,
		start_position.x - x_limit,
		start_position.x + x_limit
	)

	global_position.z = clampf(
		global_position.z,
		start_position.z - z_limit,
		start_position.z + z_limit
	)
