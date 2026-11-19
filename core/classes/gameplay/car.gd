## Класс, реализующий машину, в которой едет персонаж.
class_name Car extends Node3D


@export var character: Character
@export var anim: AnimationPlayer

var dialog: bool = false


func start() -> void:
	show()
	anim.play("start")


func to_accept() -> void:
	anim.play("accept")


func deny() -> void:
	anim.play("deny")


func get_resume() -> String:
	return character.resume


func get_social_networks() -> Array[String]:
	return character.social_networks


func get_character() -> Character:
	return character
