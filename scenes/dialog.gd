## Скрипт для диалогов, между персонажами
extends Panel

@export var container: HBoxContainer


func start_dialog(dialogs: Dictionary[String, Array], start_phrase: String):
	$Label.text = start_phrase
	
	for child in container.get_children(): # Очищаем все предыдущие вопросы
		child.queue_free()
	
	for question in dialogs: # Создаём новые вопросы
		var button = Button.new()
		button.text = question
		button.pressed.connect(play.bind(dialogs[question]))
		
		container.add_child(button)


func play(text: String):
	$Label.text = text
