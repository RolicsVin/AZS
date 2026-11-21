class_name Button_manager extends Node3D

var camera_enabled: bool = true
var settings_tween: Tween


func play() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func settings() -> void:
	var ui = $"../UI/settings"

	# Не открываем настройки повторно.
	if ui.visible:
		return

	camera_enabled = false

	# Пока настройки открыты, блокируем 3D-кнопки меню,
	# чтобы клик по Back не срабатывал на кнопке позади UI.
	$Play.active = false
	$Play2.active = false
	$Play3.active = false

	ui.show()
	ui.modulate.a = 0.0

	if settings_tween and settings_tween.is_running():
		settings_tween.kill()

	settings_tween = create_tween()
	settings_tween.set_trans(Tween.TRANS_LINEAR)
	settings_tween.tween_property(ui, "modulate:a", 1.0, 0.2)


func quit() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	var ui = $"../UI/settings"

	# Не выполняем закрытие повторно.
	if not ui.visible:
		return

	if settings_tween and settings_tween.is_running():
		settings_tween.kill()

	settings_tween = create_tween()
	settings_tween.set_trans(Tween.TRANS_LINEAR)
	settings_tween.tween_property(ui, "modulate:a", 0.0, 0.2)
	settings_tween.tween_callback(ui.hide)
	settings_tween.tween_callback(_enable_menu_buttons)


func _enable_menu_buttons() -> void:
	$Play.active = true
	$Play2.active = true
	$Play3.active = true
	camera_enabled = true
