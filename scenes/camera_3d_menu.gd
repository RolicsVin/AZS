

extends Camera3D

@export_category("Hold Points")
@export var rotation_point: Node3D
@export var position_point: Node3D

@export_category("Rotation")
@export var speed: float = 5.0
@export var limit: float = 10.0
@export var mouse_sensitivity: float = 0.1

@export_category("Position Movement")
@export var position_speed: float = 5.0

@export_category("Mouse State")
@export_range(0.0, 0.5, 0.01) var dead_zone: float = 0.05

@export_category("Position Mouse Follow")
@export var position_mouse_sensitivity: float = 0.001
@export var position_mouse_limit: float = 0.5
@export var position_mouse_speed: float = 3.0

@export var LookPoint: bool = true

var mouse_rotation: Vector2 = Vector2.ZERO
var position_mouse_offset: Vector2 = Vector2.ZERO

var position_mode: bool = false

# Если скрипт используется вне меню, узел Buttons может отсутствовать.
@onready var button_manager: Node = get_node_or_null("../Buttons")


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	

func _input(event: InputEvent) -> void:
	if not _camera_input_enabled():
		return

	if event is InputEventMouseMotion:

		if not position_mode:
			mouse_rotation.x -= event.relative.y * mouse_sensitivity
			mouse_rotation.y -= event.relative.x * mouse_sensitivity

			mouse_rotation.x = clampf(mouse_rotation.x, -limit, limit)
			mouse_rotation.y = clampf(mouse_rotation.y, -limit, limit)

		else:
			# Движение камеры за мышью без инверсии.
			position_mouse_offset.x += event.relative.x * position_mouse_sensitivity
			position_mouse_offset.y -= event.relative.y * position_mouse_sensitivity

			position_mouse_offset.x = clampf(
				position_mouse_offset.x,
				-position_mouse_limit,
				position_mouse_limit
			)

			position_mouse_offset.y = clampf(
				position_mouse_offset.y,
				-position_mouse_limit,
				position_mouse_limit
			)


func _process(delta: float) -> void:
	if is_instance_valid(button_manager) and not button_manager.camera_enabled:
		return

	var viewport_size := get_viewport().get_visible_rect().size
	var mouse_y := get_viewport().get_mouse_position().y
	var mouse_ratio := mouse_y / viewport_size.y

	# Переключение режимов.
	if position_mode:
		# Из Position выходим только через верхнюю зону.
		if mouse_ratio <= dead_zone:
			position_mode = false
			position_mouse_offset = Vector2.ZERO
	else:
		# В Position переходим только через нижнюю зону.
		if mouse_ratio >= 1.0 - dead_zone:
			position_mode = true
			position_mouse_offset = Vector2.ZERO

	var target_point: Node3D

	if position_mode:
		target_point = position_point
	else:
		target_point = rotation_point

	if not is_instance_valid(target_point):
		return

	# Базовая позиция Hold Point.
	var target_position := target_point.global_position

	if position_mode:
		# Смещение относительно локальных осей Hold Point.
		var right := target_point.global_transform.basis.x
		var up := target_point.global_transform.basis.y

		target_position += right * position_mouse_offset.x
		target_position += up * position_mouse_offset.y

	# Плавное перемещение камеры.
	global_position = global_position.lerp(
		target_position,
		clampf(position_speed * delta, 0.0, 1.0)
	)

	# Целевая ротация.
	var target_rotation := target_point.global_rotation

	if position_mode:
		global_rotation = global_rotation.slerp(
			target_rotation,
			clampf(position_mouse_speed * delta, 0.0, 1.0)
		)
	else:
		if LookPoint:
			target_rotation += Vector3(
				deg_to_rad(mouse_rotation.x),
				deg_to_rad(mouse_rotation.y),
				0.0
			)

		global_rotation = global_rotation.slerp(
			target_rotation,
			clampf(speed * delta, 0.0, 1.0)
		)


func _camera_input_enabled() -> bool:
	if not is_instance_valid(button_manager):
		return true

	# Узел Buttons в этой сцене может быть обычным Node3D без менеджера.
	for property in button_manager.get_property_list():
		if property.name == "camera_enabled":
			return button_manager.get("camera_enabled") == true

	return true

func snap_to_rotation_point() -> void:
	if not is_instance_valid(rotation_point):
		return

	position_mode = false
	position_mouse_offset = Vector2.ZERO
	global_position = rotation_point.global_position

	var target_rotation := rotation_point.global_rotation
	if LookPoint:
		target_rotation += Vector3(
			deg_to_rad(mouse_rotation.x),
			deg_to_rad(mouse_rotation.y),
			0.0
		)
	global_rotation = target_rotation
