## Отвечает только за отображение и выбор вариантов ответа.
class_name ChoiceVisual
extends Control

signal choice_changed(index: int)
signal choice_confirmed(index: int)

@export var chooser: Control

var current_choice: int = -1
var locked: bool = false

var _container: Control
var _labels: Array[Label] = []
var _active_tween: Tween


func _ready() -> void:
	if chooser == null:
		chooser = get_node_or_null("Chooser") as Control
	hide()


## Один раз связывает визуальный компонент с контейнером вариантов.
func setup(container: Control) -> void:
	_container = container


## Создаёт и отображает варианты ответа.
func display_choices(answers: Array[String]) -> void:
	clear()
	if _container == null or answers.is_empty():
		return

	locked = false
	current_choice = -1

	for answer in answers:
		var label := Label.new()
		label.text = answer
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_container.add_child(label)
		_labels.append(label)
		_add_underline(label)

	show()


## Удаляет варианты и сбрасывает состояние компонента.
func clear() -> void:
	_kill_tween()
	for label in _labels:
		if is_instance_valid(label):
			label.queue_free()
	_labels.clear()
	current_choice = -1
	locked = false


## Программно устанавливает выбранный вариант.
func set_selected(index: int) -> void:
	if locked or index < 0 or index >= _labels.size():
		return
	if current_choice == index:
		return

	current_choice = index
	_update_selection_visuals()
	choice_changed.emit(current_choice)


## Запускает анимацию подтверждения текущего варианта.
func confirm() -> void:
	if locked or current_choice < 0 or current_choice >= _labels.size():
		return

	locked = true
	_kill_tween()
	_active_tween = create_tween()
	_active_tween.set_parallel(true)

	for index in range(_labels.size()):
		var label := _labels[index]
		if index == current_choice:
			_active_tween.tween_property(label, "scale", Vector2(1.12, 1.12), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			_active_tween.tween_property(label, "modulate:a", 0.0, 0.3).set_delay(0.18)
		else:
			_active_tween.tween_property(label, "modulate:a", 0.0, 0.18)

		var underline := label.get_node_or_null("ChoiceUnderline") as Panel
		if underline != null:
			_active_tween.tween_property(underline, "scale:x", 0.0, 0.18)
			_active_tween.tween_property(underline, "modulate:a", 0.0, 0.18)

	var confirmed_index := current_choice
	_active_tween.finished.connect(func() -> void:
		choice_confirmed.emit(confirmed_index)
	)


func _process(_delta: float) -> void:
	if not visible or locked or _labels.is_empty():
		return

	var mouse_position := get_viewport().get_mouse_position()
	var center := get_viewport_rect().size * 0.5
	var direction := mouse_position - center

	if direction.length_squared() < 1.0:
		return

	if chooser != null:
		chooser.rotation = (mouse_position - chooser.get_global_transform_with_canvas().origin).angle()

	# Нулевой сектор направлен вправо; остальные равномерно распределены по окружности.
	var sector_size := TAU / float(_labels.size())
	var angle := fposmod(direction.angle(), TAU)
	var selected_index := int(floor((angle + sector_size * 0.5) / sector_size)) % _labels.size()
	set_selected(selected_index)


func _add_underline(label: Label) -> void:
	var panel := Panel.new()
	panel.name = "ChoiceUnderline"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.show_behind_parent = true
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = -6.0
	panel.offset_right = 6.0
	panel.pivot_offset = Vector2(label.size.x * 0.5, label.size.y * 0.5)

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
	label.add_child(panel)


func _update_selection_visuals() -> void:
	_kill_tween()
	_active_tween = create_tween()
	_active_tween.set_parallel(true)

	for index in range(_labels.size()):
		var label := _labels[index]
		var selected := index == current_choice
		label.modulate = Color.WHITE if selected else Color(0.65, 0.65, 0.65, 1.0)

		var underline := label.get_node_or_null("ChoiceUnderline") as Control
		if underline == null:
			continue

		_active_tween.tween_property(underline, "modulate:a", 1.0 if selected else 0.0, 0.2)
		_active_tween.tween_property(underline, "scale:x", 1.08 if selected else 0.0, 0.3 if selected else 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _kill_tween() -> void:
	if _active_tween != null and _active_tween.is_running():
		_active_tween.kill()
	_active_tween = null
