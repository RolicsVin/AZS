class_name Button_manager extends Node3D

var camera_enabled = true


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func play() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func settings() -> void:
	camera_enabled = false

	var ui = $"../UI/settings"
	ui.show()
	ui.modulate.a = 0

	var tween = create_tween()
	tween.tween_property(ui, "modulate:a", 1.0, 0.3)


func quit() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	var ui = $"../UI/settings"

	var tween = create_tween()
	tween.tween_property(ui, "modulate:a", 0.0, 0.3)
	tween.tween_callback(ui.hide)
	tween.tween_callback(func(): camera_enabled = true)
