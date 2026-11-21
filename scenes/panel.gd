## Скрипт для отображения текста социальных сетей
extends Panel

@export var container: VBoxContainer


func set_text(texts: Array[String]) -> void: ## Установить текст социальных сетей
	show()

	for child in container.get_children():
		child.queue_free()

	for post in texts:
		# PanelContainer подстраивает минимальную высоту под содержимое.
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

		var label := Label.new()
		label.text = post
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

		panel.add_child(label)
		container.add_child(panel)
