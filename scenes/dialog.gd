## Скрипт для диалогов, между персонажами
extends Panel

@export var container: HBoxContainer


func start_dialog(dialogs: Dictionary[String, Array], start_phrase: String):
	$Label.text = start_phrase
	
	for child in container.get_children(): # очищаем все предыдущие вопросы
		child.queue_free()
	
	for question in dialogs:
		var button = Button.new()
		button.text = question
		button.connect(func(t=dialogs[question]): return play(t))
		
		container.add_child(button)


func play(text: String):
	$Label.text = text
