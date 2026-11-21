## Управляет состоянием диалога и переходами между его узлами.
extends Control

signal dialog_finished

@export var container: CircularContainer
@export var choice_visual: ChoiceVisual

@export_category("Настройки выбора")
@export var choice_font_size: int = 8

var character: Character
var current_dialog: LinearDialog
var replica_index: int = -1
var is_active: bool = false

var _dialog_by_name: Dictionary[String, LinearDialog] = {}
var _choice_by_name: Dictionary[String, Choise] = {}
var _choice_dialog_names: Array[String] = []


func _ready() -> void:
	if container == null:
		push_error("Dialog: не назначен контейнер вариантов ответа.")
		return

	if choice_visual == null:
		push_error("Dialog: не назначен ChoiceVisual.")
		return

	choice_visual.setup(container)
	choice_visual.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if not choice_visual.choice_changed.is_connected(_on_choice_changed):
		choice_visual.choice_changed.connect(_on_choice_changed)

	if not choice_visual.choice_confirmed.is_connected(_on_choice_confirmed):
		choice_visual.choice_confirmed.connect(_on_choice_confirmed)


func start_dialog(target_character: Character) -> void:
	if is_active or target_character == null or target_character.dialog_end:
		return

	character = target_character
	_build_resource_indexes()

	if character.start_dialog.is_empty() or not _play_dialog(character.start_dialog):
		character = null
		return

	is_active = true
	character.dialog_end = true

	show()
	get_parent().show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(_delta: float) -> void:
	if not is_active or not Input.is_action_just_pressed("left_mouse"):
		return

	if choice_visual.visible:
		confirm_choice()
	elif current_dialog != null and not current_dialog.replicas.is_empty():
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


func _play_dialog(dialog_name: String) -> bool:
	var dialog := _dialog_by_name.get(dialog_name) as LinearDialog

	if dialog == null:
		push_error("Dialog: диалог '%s' не найден у персонажа." % dialog_name)
		return false

	_clear_choices()
	choice_visual.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	replica_index = -1
	current_dialog = dialog
	return true


func _show_choices(choice_name: String) -> void:
	_clear_choices()

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

	_choice_dialog_names.clear()
	var answers: Array[String] = []

	for answer_text in choice.choises:
		answers.append(str(answer_text))
		_choice_dialog_names.append(choice.choises[answer_text])

	choice_visual.display_choices(answers)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _on_choice_changed(choice_index: int) -> void:
	if not is_active:
		return


func _on_choice_confirmed(choice_index: int) -> void:
	if not is_active or choice_index < 0 or choice_index >= _choice_dialog_names.size():
		return

	var next_dialog_name := _choice_dialog_names[choice_index]
	choice_visual.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if not _play_dialog(next_dialog_name):
		_finish_dialog()


func _finish_dialog() -> void:
	if not is_active:
		return

	current_dialog = null
	replica_index = -1
	_choice_dialog_names.clear()
	_clear_choices()
	$Label.text = ""

	choice_visual.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	is_active = false
	dialog_finished.emit()


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


func _clear_choices() -> void:
	_choice_dialog_names.clear()
	if choice_visual != null:
		choice_visual.clear()
