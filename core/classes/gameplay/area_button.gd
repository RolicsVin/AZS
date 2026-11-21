## Кнопка-область. 
class_name AreaButon extends Area3D

signal pressed ## Издаётся, когда был вызван метод "press"

@export var active: bool = true
var inarea: bool = false


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func on() -> void:
	active = true


func off() -> void:
	active = false


func press() -> void:
	if not active:
		return
	pressed.emit()


func _process(_delta: float) -> void:
	if inarea:
		if Input.is_action_just_pressed("left_mouse"):
			press()


func _on_mouse_entered() -> void: 
	if not active:
		return
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	inarea = true


func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	inarea = false
