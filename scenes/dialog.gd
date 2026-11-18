## Скрипт для диалогов, между персонажами
extends Control

@export var container: CircularContainer
@export var button: PackedScene

var curent_dialog: LinearDialog
var id: int = -1 ## Текущей номер фразы. В начале фразы нет, поэтому -1


func start_dialog(dialogs: Array, start_phrase: LinearDialog) -> void:
	show()
	get_parent().show()
	play(start_phrase)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_mouse"):
		if not curent_dialog or not curent_dialog.replicas:
			return
		next()


func play(dialog: LinearDialog) -> void: ## Запустить диалог
	id = -1 # Сбрасываем id назад
	curent_dialog = dialog
	# логично было бы вызывать next(), но он срабатывает в _process


func next() -> void: ## Покажет следующий текст
	if not curent_dialog or not curent_dialog.replicas:
		return
	id += 1
	
	if id > len(curent_dialog.replicas) - 1:
		qustions(curent_dialog.choise)
		$Label.text = ''
		return
	
	$Label.text = curent_dialog.replicas[id]


func qustions(choise: Choise) -> void:
	clear_choises()
	
	for c in choise.choises: # Создаём новые вопросы
		var button: Button = button.instantiate()
		button.text = c
		button.choise = choise.choises[c]
		button.choised.connect(play)
		
		container.add_child(button)


func clear_choises() -> void: ## Очистит список вопросов
	for child in container.get_children(): # Очищаем все предыдущие вопросы
		child.queue_free()
