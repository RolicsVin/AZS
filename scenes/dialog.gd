## Управляет состоянием диалога и переходами между его узлами.
extends Control

signal dialog_started
signal dialog_finished
## Запрашивает применение изменения репутации; само состояние изменяет Game.
signal respect_reward_requested(delta: int)

## Контейнер, в котором ChoiceVisual размещает варианты ответа.
@export var container: CircularContainer
## Компонент отображения и подтверждения вариантов ответа.
@export var choice_visual: ChoiceVisual
## Камера, переключение режимов которой блокируется на время диалога.
@export var camera: Camera3D

@export_category("Настройки выбора")
## Размер шрифта текста вариантов ответа.
@export var choice_font_size: int = 8

## Персонаж, чьи реплики и варианты ответа воспроизводятся.
var character: Character
## Текущий линейный фрагмент диалога.
var current_dialog: LinearDialog
## Индекс последней показанной реплики текущего диалога.
var replica_index: int = -1
## Выполняется ли сейчас диалоговая цепочка.
var is_active: bool = false
## Ожидает ли система выбора варианта ответа.
var is_waiting_for_choice: bool = false

## Индекс линейных диалогов персонажа по имени.
var _dialog_by_name: Dictionary[String, LinearDialog] = {}
## Индекс ресурсов Choise персонажа по имени.
var _choice_by_name: Dictionary[String, Choise] = {}
## Имена диалогов, соответствующие вариантам текущего выбора.
var _choice_dialog_names: Array[String] = []
## Изменения репутации, соответствующие вариантам текущего выбора.
var _choice_respect_rewards: Array[int] = []
## Идентификаторы персонажей, чьи диалоги уже завершены этим экземпляром Dialog.
var _finished_characters: Dictionary = {}


## Проверяет обязательные UI-ссылки, настраивает визуализацию вариантов и подключает сигнал подтверждения.
func _ready() -> void:
	if container == null:
		push_error("Dialog: не назначен контейнер вариантов ответа.")
		return

	if choice_visual == null:
		push_error("Dialog: не назначен ChoiceVisual.")
		return

	choice_visual.setup(container, choice_font_size)
	choice_visual.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if not choice_visual.choice_confirmed.is_connected(_on_choice_confirmed):
		choice_visual.choice_confirmed.connect(_on_choice_confirmed)


## Начинает диалог персонажа, если он корректен, ещё не завершён и другая цепочка не активна.
func start_dialog(target_character: Character) -> bool:
	if is_active or target_character == null:
		return false
	var character_id: int = target_character.get_instance_id()
	if _finished_characters.has(character_id):
		return false
	if not target_character.validate_configuration():
		return false

	character = target_character
	_build_resource_indexes()

	# Активируем диалог до _play_dialog(), поскольку он сразу выводит первую реплику.
	is_active = true
	if character.start_dialog.is_empty() or not _play_dialog(character.start_dialog):
		is_active = false
		character = null
		return false

	dialog_started.emit()

	# На время диалога фиксируем камеру в верхнем режиме.
	if is_instance_valid(camera):
		camera.mode_switching_enabled = false
		camera.force_rotation_mode()

	show()
	get_parent().show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	return true


## Обрабатывает нажатие мыши: показывает следующую реплику или подтверждает вариант.
func _process(_delta: float) -> void:
	if not is_active or not Input.is_action_just_pressed("left_mouse"):
		return

	if choice_visual.visible:
		confirm_choice()
	elif current_dialog != null:
		next_replica()


## Показывает следующую реплику текущего диалога.
func next_replica() -> void:
	if not is_active or current_dialog == null:
		return

	replica_index += 1

	if replica_index >= current_dialog.replicas.size():
		var next_choice := current_dialog.next_choise
		$Label.text = ""
		current_dialog = null
		_show_choices(next_choice)
		return

	$Label.text = current_dialog.replicas[replica_index]


## Подтверждает текущий вариант ответа.
func confirm_choice() -> void:
	if not is_active or choice_visual == null:
		return

	choice_visual.confirm()


## Находит линейный диалог по имени, сбрасывает выбор и начинает показ реплик.
func _play_dialog(dialog_name: String) -> bool:
	var dialog := _dialog_by_name.get(dialog_name) as LinearDialog

	if dialog == null:
		push_error("Dialog: диалог '%s' не найден у персонажа." % dialog_name)
		return false

	_clear_choices()
	choice_visual.hide()
	is_waiting_for_choice = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	replica_index = -1
	current_dialog = dialog

	# Не ждём следующего нажатия: первая реплика появляется сразу при переходе.
	next_replica()
	return true


## Показывает варианты ответа и переводит систему в состояние ожидания выбора.
func _show_choices(choice_name: String) -> void:
	_clear_choices()
	# Переход к Choise — часть того же диалога, а не его завершение.
	is_active = true
	is_waiting_for_choice = true

	if choice_name.is_empty():
		_finish_dialog()
		return

	var choice := _choice_by_name.get(choice_name) as Choise
	if choice == null:
		push_error("Dialog: выбор '%s' не найден у персонажа." % choice_name)
		_finish_dialog()
		return

	if choice.choises.is_empty():
		_finish_dialog()
		return

	var answers: Array[String] = []
	for answer_text in choice.choises:
		var target_dialog: String = choice.choises[answer_text]
		answers.append(str(answer_text))
		_choice_dialog_names.append(target_dialog)
		# Награда индексируется именем диалога назначения (например, "agro"), а не текстом ответа.
		_choice_respect_rewards.append(choice.respect_rewards.get(target_dialog, 0))

	choice_visual.display_choices(answers)
	if not choice_visual.visible:
		push_error("Dialog: не удалось отобразить варианты выбора '%s'." % choice_name)
		_finish_dialog()
		return
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


## Переходит к диалогу, связанному с подтверждённым вариантом ответа.
func _on_choice_confirmed(choice_index: int) -> void:
	if not is_active or not is_waiting_for_choice or choice_index < 0 or choice_index >= _choice_dialog_names.size():
		return

	var next_dialog_name := _choice_dialog_names[choice_index]
	var respect_delta: int = _choice_respect_rewards[choice_index]
	is_waiting_for_choice = false
	choice_visual.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if respect_delta != 0:
		respect_reward_requested.emit(respect_delta)

	if not _play_dialog(next_dialog_name):
		_finish_dialog()


## Сбрасывает состояние цепочки, запоминает завершённого персонажа и отправляет dialog_finished.
func _finish_dialog() -> void:
	if not is_active:
		return

	current_dialog = null
	replica_index = -1
	is_waiting_for_choice = false
	_choice_dialog_names.clear()
	_choice_respect_rewards.clear()
	_clear_choices()
	$Label.text = ""

	choice_visual.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	is_active = false
	if character != null:
		_finished_characters[character.get_instance_id()] = true

	# После диалога возвращаем обычное переключение режимов камеры.
	if is_instance_valid(camera):
		camera.mode_switching_enabled = true

	dialog_finished.emit()


## Строит словари диалогов и вариантов ответа для быстрого поиска по имени.
func _build_resource_indexes() -> void:
	_dialog_by_name.clear()
	_choice_by_name.clear()

	for dialog in character.dialogs:
		if dialog == null:
			continue
		if _dialog_by_name.has(dialog.name):
			push_warning("Dialog: повторяется имя диалога '%s'." % dialog.name)
			continue
		_dialog_by_name[dialog.name] = dialog

	for choice in character.choises:
		if choice == null:
			continue
		if _choice_by_name.has(choice.name):
			push_warning("Dialog: повторяется имя выбора '%s'." % choice.name)
			continue
		_choice_by_name[choice.name] = choice


## Очищает список переходов, наград и визуальные варианты ответа.
func _clear_choices() -> void:
	_choice_dialog_names.clear()
	_choice_respect_rewards.clear()
	if choice_visual != null:
		choice_visual.clear()
