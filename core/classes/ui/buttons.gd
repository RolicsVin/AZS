class_name Button_manager extends Node3D

var camera_enabled: bool = true


func play() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func settings() -> void:
	camera_enabled = false
	$"../UI/settings".show()


func quit() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	$"../UI/settings".hide()
	camera_enabled = true
