class_name Button_manager extends Node3D

var camera_enabled: bool = true
var settings_tween: Tween


func play() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func settings() -> void:
	camera_enabled = false

	var ui = $"../UI/settings"
	ui.show()
	ui.modulate.a = 0.0

	# Не допускаем наложения анимаций при повторном нажатии.
	if settings_tween and settings_tween.is_running():
		settings_tween.kill()

	# Только плавное изменение прозрачности, без масштабирования и bounce.
	settings_tween = create_tween()
	settings_tween.set_trans(Tween.TRANS_LINEAR)
	settings_tween.tween_property(ui, "modulate:a", 1.0, 0.2)


func quit() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	camera_enabled = true
	var ui = $"../UI/settings"
	ui.hide()
