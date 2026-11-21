class_name Button_manager extends Node3D

var camera_enabled: bool = true
var settings_tween: Tween


func play() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func settings() -> void:
	var ui = $"../UI/settings"

	# Не открываем настройки повторно, если они уже открыты
	# или ещё выполняется их закрытие.
	if ui.visible:
		return

	camera_enabled = false
	ui.show()
	ui.modulate.a = 0.0

	# Не допускаем наложения анимаций при повторном нажатии.
	if settings_tween and settings_tween.is_running():
		settings_tween.kill()

	settings_tween = create_tween()
	settings_tween.set_trans(Tween.TRANS_LINEAR)
	settings_tween.tween_property(ui, "modulate:a", 1.0, 0.2)


func quit() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	var ui = $"../UI/settings"

	# Игнорируем повторный вызов Back, если настройки уже скрыты.
	if not ui.visible:
		return

	if settings_tween and settings_tween.is_running():
		settings_tween.kill()

	# Скрываем настройки обычным fade-out без bounce.
	settings_tween = create_tween()
	settings_tween.set_trans(Tween.TRANS_LINEAR)
	settings_tween.tween_property(ui, "modulate:a", 0.0, 0.2)
	settings_tween.tween_callback(ui.hide)
	settings_tween.tween_callback(func(): camera_enabled = true)
