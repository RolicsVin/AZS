## Контроллер игрока от первого лица. 
## Управляет перемещением персонажа, обзором мышью и захватом курсора. 
class_name Player extends CharacterBody3D


@export_category("Camera")
@export var camera: Camera3D
@export_range(0.001, 1.0, 0.001) var mouse_sensitivity: float = 0.1
@export_range(60.0, 89.9, 0.1) var max_look_angle: float = 89.0

@export_category("Movement")
@export_range(0.1, 20.0, 0.1) var move_speed: float = 5.0
@export_range(0.1, 20.0, 0.1) var jump_velocity: float = 4.5


func _ready() -> void:
	if camera == null:
		push_warning("Player: Camera3D не назначена в свойстве camera.")
	else:
		camera.make_current()

	_capture_mouse()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_release_mouse()
			get_viewport().set_input_as_handled()
			return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_capture_mouse()
			get_viewport().set_input_as_handled()
			return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_rotate_camera(event.relative)


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement()
	_handle_jump()
	move_and_slide()


## Поворачивает персонажа по горизонтали, а камеру — по вертикали.
func _rotate_camera(mouse_delta: Vector2) -> void:
	rotate_y(deg_to_rad(-mouse_delta.x * mouse_sensitivity))

	if camera == null:
		return

	var pitch := camera.rotation.x - deg_to_rad(mouse_delta.y * mouse_sensitivity)
	var max_pitch := deg_to_rad(max_look_angle)
	camera.rotation.x = clampf(pitch, -max_pitch, max_pitch)


## Перемещает персонажа относительно направления его взгляда.
func _handle_movement() -> void:
	var input_direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)
	var direction := (global_basis * Vector3(input_direction.x, 0.0, input_direction.y)).normalized()

	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed


## Применяет гравитацию, заданную в настройках проекта.
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


## Выполняет прыжок при нажатии ui_accept (по умолчанию — Space/Enter).
func _handle_jump() -> void:
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_velocity


## Захватывает курсор мыши.
func _capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


## Освобождает курсор мыши.
func _release_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
