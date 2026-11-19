## Скрипт для диалогов между персонажами.
extends Control

@export var container: CircularContainer
@export var button: PackedScene

var character: Character
var curent_dialog: LinearDialog
var id: int = -1 ## Текущий номер реплики

var end: bool = true


func start_dialog(target_character: Character) -> void:
	if not end or target_character.dialog_end:
		return
	end = false
	target_character.dialog_end = true
	character = target_character
	show()
	get_parent().show()
	play(character.start_dialog)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_mouse"):
		if not curent_dialog or not curent_dialog.replicas:
			return
		next()


func play(dialog_name: String) -> void: ## Запустить диалог по имени
	var dialog := _find_dialog(dialog_name)
	
	if not dialog:
		push_error("Диалог с именем '%s' не найден у персонажа." % dialog_name)
		return
	
	clear_choises()
	id = -1
	
	curent_dialog = dialog


func next() -> void: ## Показать следующую реплику
	if not curent_dialog:
		return

	id += 1
	if id >= curent_dialog.replicas.size():
		var choise_name := curent_dialog.next_choise
		$Label.text = ""
		
		if not curent_dialog.next_choise: # Защита от ложного срабатывания
			end = true
		
		show_choises(choise_name)
		curent_dialog = null
		return

	$Label.text = curent_dialog.replicas[id]


func show_choises(choise_name: String) -> void: ## Показать кнопки
	clear_choises()

	if choise_name.is_empty():
		_finish_dialog()
		return

	var choise := _find_choise(choise_name)
	if not choise:
		push_error("Выбор с именем '%s' не найден у персонажа." % choise_name)
		_finish_dialog()
		return

	if choise.choises.is_empty():
		_finish_dialog()
		return

	for answer_text in choise.choises:
		var choice_button := button.instantiate()
		choice_button.text = answer_text
		choice_button.dialog_name = choise.choises[answer_text]
		choice_button.choised.connect(play)
		container.add_child(choice_button)


func _finish_dialog() -> void:
	curent_dialog = null
	clear_choises()
	$Label.text = ""

	# Вызываем общий выход из интерфейса и возвращаем управление игроку.
	get_parent().get_parent().player_continue()


func _find_dialog(dialog_name: String) -> LinearDialog:
	for dialog in character.dialogs:
		if dialog.name == dialog_name:
			return dialog
	return null


func _find_choise(choise_name: String) -> Choise:
	for choise in character.choises:
		if choise.name == choise_name:
			return choise
	return null


func clear_choises() -> void: ## Очистить список вариантов ответа
	for child in container.get_children():
		child.queue_free()
