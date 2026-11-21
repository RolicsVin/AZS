## Кнопка-область.
class_name AreaButon extends Area3D

signal pressed ## Издаётся, когда был вызван метод "press"

@export var active: bool = true
var inarea: bool = false


func _ready() -> void:
	# Сигналы mouse_entered/mouse_exited у CollisionObject3D
	# работают только при включённом physics object picking у Viewport.
	get_viewport().physics_object_picking = true
	input_ray_pickable = true

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func on() -> void:
	active = true


func off() -> void:
	active = false
	if inarea:
		inarea = false
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)


func press() -> void:
	if not active:
		return
	pressed.emit()


func _process(_delta: float) -> void:
	if inarea and Input.is_action_just_pressed("left_mouse"):
		press()


func _on_mouse_entered() -> void:
	if not active:
		return

	inarea = true
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_POINTING_HAND)


func _on_mouse_exited() -> void:
	inarea = false
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
