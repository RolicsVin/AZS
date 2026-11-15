## Скрипт для отображения текста социальных сетей
extends Panel

@export var container: VBoxContainer


func set_text(texts: Array[String]) -> void: ## Установить текст социальных сетей
	for i in texts:
		# Создаём панель
		var panel = Panel.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND
		
		# Создаём текст
		var text = Label.new()
		text.set_anchors_preset(Control.PRESET_FULL_RECT)
		text.text = i
		
		# Заканчиваем настройку
		panel.add_child(text)
		container.add_child(panel)
