## Главный координатор: связывает системы и реагирует на игровые события.
extends Node3D

@export var works: Array[Work]
@export_file('*.json') var content_path: String = 'res://content/content.json' ## Файл контента
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

var current_car: Car
var waiting_for_event: bool = false
var dialog_session_active: bool = false

var sequence_controller: SequenceController
var ui_controller: UIController
var decision_service: DecisionService
var event_service: EventService
var event_controller: EventController
var content_applier: ContentApplier
var game_state: GameState ## Единственное хранилище денег и репутации (автозагрузка Data)
var content_report: ContentBundle ## Итог загрузки внешнего контента
var transition_pending: bool = false


func _ready() -> void:
	# Отключил ContentLoader
	# Раскоментировать, чтобы вернуть загрузку
	# Контент загружается до запуска систем: вставки должны попасть в смены заранее
	#content_report = ContentLoader.new().load_file(content_path)
	#_log_content_report(content_report)

	game_state = Data
	
	# Отключил ContentLoader
	# Раскоментировать, чтобы вернуть загрузку
	#game_state.reset(content_report.start_money, content_report.start_respect)
	#if content_report.transition_duration >= 0.0:
		#transition_duration = content_report.transition_duration

	#content_applier = ContentApplier.new()
	#for message in content_applier.apply(content_report, works):
		#push_warning('Контент: %s' % message)

	sequence_controller = SequenceController.new()
	sequence_controller.setup(works)
	
	ui_controller = UIController.new()
	ui_controller.setup(_build_ui_bindings())
	
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


## Собирает ссылки на узлы интерфейса: единственное место, знающее пути в сцене
func _build_ui_bindings() -> UIBindings:
	var bindings: UIBindings = UIBindings.new() ## Привязки для UIController
	bindings.main_ui = ui
	bindings.resume = resume
	bindings.web = web
	bindings.event_panel = event_panel
	bindings.dialog = dialog
	bindings.back_button = back_button
	bindings.event_card = get_node_or_null('UI/Panel') as Control
	bindings.event_label = get_node_or_null('UI/Panel/Label') as Label
	bindings.event_continue_button = get_node_or_null('UI/Button') as Control
	bindings.end_label = get_node_or_null('UI/Label') as Control
	if accert_button != null:
		bindings.decision_buttons.append(accert_button)
	if deny_button != null:
		bindings.decision_buttons.append(deny_button)
	return bindings


## Выводит в журнал итог загрузки контента и все найденные проблемы
func _log_content_report(bundle: ContentBundle) -> void:
	for message in bundle.errors:
		push_warning('Контент: %s' % message)
	print(
		'Контент: загружен=%s, событий=%d, вставок=%d, проблем=%d'
		% [bundle.is_loaded, bundle.events.size(), bundle.insertions.size(), bundle.errors.size()]
	)


## Запрашивает следующий элемент у SequenceController и передаёт его нужной системе.
func next() -> void:
	ui_controller.set_decision_buttons_enabled(false)
	current_car = null
	waiting_for_event = false

	while true:
		var entry: SequenceEntry = sequence_controller.take_next()
		event_panel.hide()
		
		if entry.finished:
			if transition_pending:
				await _fade_from_black()
				transition_pending = false
			end_game()
			return
		
		var work: Work = entry.work
		if entry.changed_work:
			await _fade_to_black()
			transition_pending = true
		
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
			if transition_pending:
				await _fade_from_black()
				transition_pending = false
			return
		
		if item is Event:
			var event := item as Event
			if event_controller.process_event(event, game_state):
				if is_instance_valid(anim) and anim.has_animation(event.anim_name):
					anim.play(event.anim_name)
				waiting_for_event = true
				if transition_pending:
					await _fade_from_black()
					transition_pending = false
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
	if decision_service.apply_decision(current_car, true, game_state):
		next()


func deny() -> void:
	if _dialog_blocks_decisions() or current_car == null or not deny_button.active:
		return
	if decision_service.apply_decision(current_car, false, game_state):
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
