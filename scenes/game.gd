## Координатор игрового цикла. Правила решений и событий вынесены в сервисы.
extends Node3D

@export var works: Array[Work]
@export var ui: Control
@export var resume: Node3D
@export var web: Panel
@export var event_panel: Control
@export var dialog: Control
@export var back_button: Button
@export var anim: AnimationPlayer
@export var transition_overlay: ColorRect
@export_range(0.0, 3.0, 0.1) var transition_duration: float = 0.5

@onready var accert_button: AreaButon = $Buttons/Accert
@onready var deny_button: AreaButon = $Buttons/Deny

var work_index: int = 0
var item_index: int = 0
var current_car: Car
var waiting_for_event: bool = false
var dialog_session_active: bool = false
var decision_service: DecisionService
var event_service: EventService


func _ready() -> void:
	decision_service = DecisionService.new()
	event_service = EventService.new()
	_set_decision_buttons_enabled(false)
	if is_instance_valid(transition_overlay):
		transition_overlay.modulate.a = 0.0
		transition_overlay.hide()
	if dialog != null and dialog.has_signal("dialog_finished"):
		var callback := Callable(self, "_on_dialog_finished")
		if not dialog.is_connected("dialog_finished", callback):
			dialog.connect("dialog_finished", callback)
	for work in works:
		if work == null:
			push_warning("Game: обнаружен пустой Work.")
		else:
			work.validate_sequence()
	next()


## Берёт следующий элемент и делегирует его обработку профильному компоненту.
func next() -> void:
	_set_decision_buttons_enabled(false)
	current_car = null
	var is_transitioning := false
	if is_instance_valid(event_panel):
		event_panel.hide()

	while work_index < works.size():
		var work: Work = works[work_index]
		if work == null:
			work_index += 1
			item_index = 0
			continue
		if is_instance_valid(anim) and not work.anim_name.is_empty():
			anim.play(work.anim_name)

		# Размер проверяется при каждом проходе: Car может динамически вставить Event.
		if item_index >= work.sequence.size():
			if work_index + 1 < works.size():
				await _fade_to_black()
				is_transitioning = true
				work_index += 1
				item_index = 0
				continue
			break

		var item: Variant = work.get_sequence_item(item_index)
		item_index += 1
		if item is Car:
			current_car = item as Car
			if not current_car.validate_configuration():
				current_car = null
				continue
			current_car.start()
			setup(current_car)
			if is_transitioning:
				await _fade_from_black()
			return
		if item is Event:
			var event := item as Event
			if event_service.apply_event(event, Data):
				if is_instance_valid(anim) and anim.has_animation(event.anim_name):
					anim.play(event.anim_name)
				_show_event(event)
				if is_transitioning:
					await _fade_from_black()
				return
			continue
		push_warning("Game: пропущен некорректный элемент #%d смены '%s'." % [item_index - 1, work.name])

	if is_transitioning:
		await _fade_from_black()
	end_game()


func _fade_to_black() -> void:
	if not is_instance_valid(transition_overlay):
		return
	transition_overlay.show()
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(transition_overlay, "modulate:a", 1.0, transition_duration)
	await tween.finished


func _fade_from_black() -> void:
	if not is_instance_valid(transition_overlay):
		return
	var tween := create_tween()
	tween.tween_property(transition_overlay, "modulate:a", 0.0, transition_duration)
	await tween.finished
	transition_overlay.hide()
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _show_event(event: Event) -> void:
	waiting_for_event = true
	event_panel.show()
	$UI/Panel/Label.text = event.event_text
	$UI/Button.hide()
	ui.show()
	$UI/Panel.show()


func setup(car: Car) -> void:
	resume.set_text(car.get_resume())


func accert() -> void:
	if _dialog_blocks_decisions() or current_car == null or not accert_button.active:
		return
	if decision_service.apply_decision(current_car, true, Data):
		next()


func deny() -> void:
	if _dialog_blocks_decisions() or current_car == null or not deny_button.active:
		return
	if decision_service.apply_decision(current_car, false, Data):
		next()


func open_web() -> void:
	if current_car == null:
		return
	ui.show()
	back_button.show()
	web.set_text(current_car.get_social_networks())


func start_dialog() -> void:
	if dialog_session_active or current_car == null or current_car.character == null:
		return
	if not current_car.character.validate_configuration():
		return

	# Блокировка действует на всю цепочку: LinearDialog -> Choise -> LinearDialog.
	dialog_session_active = true
	_set_decision_buttons_enabled(false)
	ui.show()
	back_button.hide()

	if not dialog.start_dialog(current_car.get_character()):
		# Не разблокируем кнопки, если Dialog уже выполняет другую цепочку.
		if dialog.get("is_active") != true:
			dialog_session_active = false
			_set_decision_buttons_enabled(true)


func _on_dialog_finished() -> void:
	if not dialog_session_active:
		return

	# Сигнал приходит только после завершения всей цепочки диалога.
	dialog_session_active = false
	player_continue()
	_set_decision_buttons_enabled(current_car != null and not waiting_for_event)


func _dialog_blocks_decisions() -> bool:
	return dialog_session_active or (is_instance_valid(dialog) and (dialog.get("is_active") == true or dialog.get("is_waiting_for_choice") == true))


func _set_decision_buttons_enabled(enabled: bool) -> void:
	if is_instance_valid(accert_button):
		if enabled:
			accert_button.on()
		else:
			accert_button.off()
	if is_instance_valid(deny_button):
		if enabled:
			deny_button.on()
		else:
			deny_button.off()


func player_continue() -> void:
	web.hide()
	dialog.hide()
	ui.hide()
	if waiting_for_event:
		waiting_for_event = false
		next()


func end_game() -> void:
	current_car = null
	ui.show()
	$UI/Label.show()
	$UI/Button.hide()
