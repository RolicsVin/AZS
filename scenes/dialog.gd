## Скрипт для диалогов, между персонажами
extends Panel

@export var container: HBoxContainer

var curent_dialog: Array
var id: int = -1 ## Текущей номер фразы. В начале фразы нет, поэтому -1


func start_dialog(dialogs: Dictionary[String, Array], start_phrase: String) -> void:
	show()
	get_parent().show()
	
	$Label.text = start_phrase # Устанавливаем приветствие
	id = -1 # Сбрасываем id назад
	
	curent_dialog = [] # Сбрасываем текущий диалог
	clear_questions()
	
	for question in dialogs: # Создаём новые вопросы
		var button = Button.new()
		button.text = question
		button.pressed.connect(play.bind(dialogs[question]))
		
		container.add_child(button)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_mouse"):
		next()


func play(dialog: Array) -> void: ## Запустить диалог
	id = -1 # Сбрасываем id назад
	curent_dialog = dialog
	next()


func next() -> void: ## Покажет следующий текст
	if not curent_dialog:
		return
	id = clamp(id + 1, 0, len(curent_dialog) - 1)
	$Label.text = curent_dialog[id]


func clear_questions() -> void: ## Очистит список вопросов
	for child in container.get_children(): # Очищаем все предыдущие вопросы
		child.queue_free()
