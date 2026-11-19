
class_name ChoiceVisual
extends Control

signal choice_changed(index: int)
signal choice_confirmed(index: int)

@onready var chooser: Control = $Chooser

var current_choice: int = -1
var locked: bool = false


func _ready() -> void:
	hide()


func reset_choice() -> void:
	current_choice = -1
	locked = false


func setup_choices(container: Control) -> void:
	for label in container.get_children():
		if not label is Label:
			continue

		var panel := Panel.new()
		panel.name = "ChoiceUnderline"
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.show_behind_parent = true

		panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		panel.offset_left = -6.0
		panel.offset_right = 6.0

		var style := StyleBoxFlat.new()
		style.bg_color = Color(0, 0, 0, 0)
		style.border_color = Color(0.55, 0.55, 0.55, 1.0)
		style.border_width_bottom = 11
		style.corner_radius_top_left = 10
		style.corner_radius_top_right = 10
		style.corner_radius_bottom_left = 10
		style.corner_radius_bottom_right = 10

		panel.add_theme_stylebox_override("panel", style)

		panel.modulate.a = 0.0
		panel.scale.x = 0.0
		panel.pivot_offset = Vector2(label.size.x / 2.0, label.size.y / 2.0)

		label.add_child(panel)


func _process(_delta: float) -> void:
	if not visible or locked:
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


func update_choice_visual(container: Control, selected_index: int) -> void:
	for i in range(container.get_child_count()):
		var label = container.get_child(i)

		if not label is Label:
			continue

		var panel = label.get_node_or_null("ChoiceUnderline")

		var tween := create_tween()
		tween.set_parallel(true)

		if i == selected_index:
			label.modulate = Color.WHITE

			if panel:
				tween.tween_property(panel, "modulate:a", 1.0, 0.2)

				tween.tween_property(panel, "scale:x", 1.08, 0.3)\
					.set_trans(Tween.TRANS_BACK)\
					.set_ease(Tween.EASE_OUT)

		else:
			label.modulate = Color(0.65, 0.65, 0.65, 1.0)

			if panel:
				tween.tween_property(panel, "modulate:a", 0.0, 0.2)

				tween.tween_property(panel, "scale:x", 0.0, 0.2)


func confirm_choice_animation(container: Control, selected_index: int) -> void:
	if locked:
		return

	locked = true

	var tween := create_tween()
	tween.set_parallel(true)

	for i in range(container.get_child_count()):
		var label = container.get_child(i)

		if not label is Label:
			continue

		if i == selected_index:
			tween.tween_property(label, "scale", Vector2(1.12, 1.12), 0.18)\
				.set_trans(Tween.TRANS_BACK)\
				.set_ease(Tween.EASE_OUT)

			tween.tween_property(label, "modulate:a", 0.0, 0.3)\
				.set_delay(0.18)

		else:
			tween.tween_property(label, "modulate:a", 0.0, 0.18)

			var panel = label.get_node_or_null("ChoiceUnderline")

			if panel:
				tween.tween_property(panel, "scale:x", 0.0, 0.18)
				tween.tween_property(panel, "modulate:a", 0.0, 0.18)

	tween.finished.connect(func():
		choice_confirmed.emit(selected_index)
	)
