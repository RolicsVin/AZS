## Скрипт для отображения текста социальных сетей
extends Panel

const SOCIAL_FONT: Font = preload("res://assets/fonts/FredokaOneCyrillic-Regular.ttf")

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

		# Небольшие внутренние отступы и скруглённый синий фон карточки.
		var panel_style := StyleBoxFlat.new()
		panel_style.bg_color = Color("#DCEBFA")
		panel_style.corner_radius_top_left = 5
		panel_style.corner_radius_top_right = 5
		panel_style.corner_radius_bottom_left = 5
		panel_style.corner_radius_bottom_right = 5
		panel_style.content_margin_left = 5.0
		panel_style.content_margin_top = 5.0
		panel_style.content_margin_right = 5.0
		panel_style.content_margin_bottom = 5.0
		panel.add_theme_stylebox_override("panel", panel_style)

		var label := Label.new()
		label.text = post
		label.add_theme_font_override("font", SOCIAL_FONT)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

		panel.add_child(label)
		container.add_child(panel)
