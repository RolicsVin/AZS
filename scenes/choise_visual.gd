class_name ChoiceVisual
extends Control

signal choice_changed(index: int)

@onready var chooser: Control = $Chooser

var current_choice: int = -1


func _ready() -> void:
	hide()


func reset_choice() -> void:
	current_choice = -1


func _process(_delta: float) -> void:
	if not visible:
		return

	var mouse_position := get_viewport().get_mouse_position()
	var center := get_viewport_rect().size / 2.0

	var direction := mouse_position - center

	chooser.rotation = (
		mouse_position - chooser.get_global_transform_with_canvas().origin
	).angle()

	# Левая полуокружность — вариант 1, правая — вариант 0.
	var new_choice := 1 if direction.x < 0.0 else 0

	if new_choice != current_choice:
		current_choice = new_choice
		choice_changed.emit(current_choice)
