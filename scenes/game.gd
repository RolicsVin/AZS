## Главный координатор: связывает системы и реагирует на игровые события.
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

# Оставлены для совместимости с существующими обращениями к Game.
var work_index: int = 0
var item_index: int = 0
var current_car: Car
var waiting_for_event: bool = false
var dialog_session_active: bool = false

var sequence_controller: SequenceController
var ui_controller: UIController
var decision_service: DecisionService
var event_service: EventService
var event_controller: EventController


func _ready() -> void:
	sequence_controller = SequenceController.new()
	sequence_controller.setup(works)

	ui_controller = UIController.new()
	ui_controller.setup(self)

	decision_service = DecisionService.new()
	event_service = EventService.new()
	event_controller = EventController.new()
	event_controller.setup(event_service, ui_controller)

	ui_controller.set_decision_buttons_enabled(false)

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


## Запрашивает следующий элемент у SequenceController и передаёт его нужной системе.
func next() -> void:
	ui_controller.set_decision_buttons_enabled(false)
	current_car = null
	waiting_for_event = false

	while true:
		var entry: Dictionary = sequence_controller.take_next()
		work_index = sequence_controller.work_index
		item_index = sequence_controller.item_index

		if entry.finished:
			end_game()
			return

		var work: Work = entry.work
		if entry.changed_work:
			await _fade_to_black()

		if entry.entered_work and is_instance_valid(anim) and not work.anim_name.is_empty():
			anim.play(work.anim_name)

		var item: Variant = entry.item
		if item is Car:
			current_car = item as Car
			if not current_car.validate_configuration():
				current_car = null
				continue
			current_car.start()
			setup(current_car)
			if entry.changed_work:
				await _fade_from_black()
			return

		if item is Event:
			var event := item as Event
			if event_controller.process_event(event, Data):
				if is_instance_valid(anim) and anim.has_animation(event.anim_name):
					anim.play(event.anim_name)
				waiting_for_event = true
				if entry.changed_work:
					await _fade_from_black()
				return
			continue

		push_warning(
			"Game: пропущен некорректный элемент #%d смены '%s'." %
			[int(entry.item_index), work.name]
		)


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


func setup(car: Car) -> void:
	ui_controller.show_car_resume(car)


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
	ui_controller.open_social_networks(current_car)


func start_dialog() -> void:
	if dialog_session_active or current_car == null or current_car.character == null:
		return
	if not current_car.character.validate_configuration():
		return

	# Блокировка действует на всю цепочку: LinearDialog -> Choise -> LinearDialog.
	dialog_session_active = true
	ui_controller.set_decision_buttons_enabled(false)
	ui_controller.prepare_dialog()

	if not dialog.start_dialog(current_car.get_character()):
		# Не разблокируем кнопки, если Dialog уже выполняет другую цепочку.
		if dialog.get("is_active") != true:
			dialog_session_active = false
			ui_controller.set_decision_buttons_enabled(true)


func _on_dialog_finished() -> void:
	if not dialog_session_active:
		return

	dialog_session_active = false
	player_continue()
	ui_controller.set_decision_buttons_enabled(current_car != null and not waiting_for_event)


func _dialog_blocks_decisions() -> bool:
	return dialog_session_active or (
		is_instance_valid(dialog) and
		(dialog.get("is_active") == true or dialog.get("is_waiting_for_choice") == true)
	)


func player_continue() -> void:
	ui_controller.hide_for_continue()
	if waiting_for_event:
		waiting_for_event = false
		next()


func end_game() -> void:
	current_car = null
	ui_controller.show_end_screen()
