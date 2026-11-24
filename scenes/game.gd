## Главный координатор: связывает системы и реагирует на игровые события.
extends Node3D

## Рабочие смены в порядке их прохождения.
@export var works: Array[Work]
## Путь к JSON-файлу внешнего игрового контента.
@export_file('*.json') var content_path: String = 'res://content/content.json' ## Файл контента
## Основная панель игрового интерфейса.
@export var ui: Control
## Узел отображения резюме текущего посетителя.
@export var resume: Node3D
## Панель публикаций посетителя в социальных сетях.
@export var web: Panel
## Панель отображения текста игрового события.
@export var event_panel: Control
## Узел диалоговой системы.
@export var dialog: Control
## Кнопка возврата из дополнительной панели.
@export var back_button: Button
## Проигрыватель анимаций смен и событий.
@export var anim: AnimationPlayer
## Полноэкранный слой затемнения при переходе между сменами.
@export var transition_overlay: ColorRect
## Продолжительность затемнения и появления сцены в секундах.
@export_range(0.0, 3.0, 0.1) var transition_duration: float = 0.5

## Кнопка согласия на запрос посетителя.
@onready var accert_button: AreaButon = $Buttons/Accert
## Кнопка отказа на запрос посетителя.
@onready var deny_button: AreaButon = $Buttons/Deny

## Посетитель, с которым игрок взаимодействует в данный момент.
var current_car: Car
## Ожидает ли игра продолжения после показа события.
var waiting_for_event: bool = false
## Флаг всей цепочки диалога; блокирует решения до dialog_finished.
var dialog_session_active: bool = false

## Контроллер порядка смен и элементов.
var sequence_controller: SequenceController
## Контроллер отображения интерфейса.
var ui_controller: UIController
## Сервис обработки решений игрока.
var decision_service: DecisionService
## Сервис проверки и применения эффекта события.
var event_service: EventService
## Контроллер обработки и отображения событий.
var event_controller: EventController
## Компонент применения внешнего контента к сменам.
var content_applier: ContentApplier
## Единое хранилище денег и репутации; Autoload Data.
var game_state: GameState ## Единственное хранилище денег и репутации (автозагрузка Data)
## Результат загрузки и проверки внешнего контента.
var content_report: ContentBundle ## Итог загрузки внешнего контента
## Ожидает ли завершения перехода снятие слоя затемнения.
var transition_pending: bool = false


## Инициализирует игровые системы, связывает интерфейс и диалоги, проверяет смены и запускает последовательность.
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


## Плавно закрывает сцену чёрным слоем перед переходом между сменами.
func _fade_to_black() -> void:
	if not is_instance_valid(transition_overlay):
		return
	transition_overlay.show()
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(transition_overlay, "modulate:a", 1.0, transition_duration)
	await tween.finished


## Плавно убирает чёрный слой после завершения перехода.
func _fade_from_black() -> void:
	if not is_instance_valid(transition_overlay):
		return
	var tween := create_tween()
	tween.tween_property(transition_overlay, "modulate:a", 0.0, transition_duration)
	await tween.finished
	transition_overlay.hide()
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE


## Передаёт данные посетителя в UIController для отображения резюме.
func setup(car: Car) -> void:
	ui_controller.show_car_resume(car)


## Обрабатывает согласие игрока, если диалог не блокирует решение и активна соответствующая кнопка.
func accert() -> void:
	$Dialog/CollisionShape3D.disabled = true
	if _dialog_blocks_decisions() or current_car == null or not accert_button.active:
		return
	if decision_service.apply_decision(current_car, true, game_state):
		next()


## Обрабатывает отказ игрока, если диалог не блокирует решение и активна соответствующая кнопка.
func deny() -> void:
	$Dialog/CollisionShape3D.disabled = true
	if _dialog_blocks_decisions() or current_car == null or not deny_button.active:
		return
	if decision_service.apply_decision(current_car, false, game_state):
		next()


## Открывает публикации текущего посетителя через UIController.
func open_web() -> void:
	if current_car == null:
		return
	ui_controller.open_social_networks(current_car)


## Запускает диалог текущего посетителя и блокирует решения на всю цепочку реплик и выборов.
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


## Обрабатывает завершение диалоговой цепочки и возвращает доступность решений.
func _on_dialog_finished() -> void:
	if not dialog_session_active:
		return

	dialog_session_active = false
	player_continue()
	ui_controller.set_decision_buttons_enabled(current_car != null and not waiting_for_event)


## Проверяет признаки активного диалога, при которых решения должны быть заблокированы.
func _dialog_blocks_decisions() -> bool:
	return dialog_session_active or (
		is_instance_valid(dialog) and
		(dialog.get("is_active") == true or dialog.get("is_waiting_for_choice") == true)
	)


## Закрывает экран события или дополнительную панель и продолжает последовательность.
func player_continue() -> void:
	ui_controller.hide_for_continue()
	if waiting_for_event:
		waiting_for_event = false
		next()


## Завершает игровой цикл и передаёт UIController управление финальным экраном.
func end_game() -> void:
	current_car = null
	ui_controller.show_end_screen()
