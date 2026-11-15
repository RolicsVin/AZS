## Скрипт для отображения текста социальных сетей
extends Panel

@export var container: VBoxContainer


func set_text(texts: Array[String]) -> void: ## Установить текст социальных сетей
	show()
	for i in container.get_children(): # Очищаем все предыдущие записи
		i.queue_free()
	
	for i in texts:
		# Создаём панель
		var panel = Panel.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND
		panel.custom_minimum_size.y = 50
		
		# Создаём текст
		var text = Label.new()
		text.set_anchors_preset(Control.PRESET_FULL_RECT)
		text.text = i
		
		# Заканчиваем настройку
		panel.add_child(text)
		container.add_child(panel)
