## Класс, реализующий машину, в которой едет персонаж.
class_name Car extends Node3D

@export var given_money_min: int = 10
@export var given_money_max: int = 15
@export var given_respect_min: int = 10
@export var given_respect_max: int = 15
@export var character: Character
@export var anim: AnimationPlayer

var dialog: bool = false


func start() -> void:
	show()
	anim.play("start")
	


func to_accept() -> void:
	anim.play("accept")
	Data.money += randi_range(given_money_min, given_money_max)
	Data.respect += randi_range(given_respect_min, given_respect_min)


func deny() -> void:
	anim.play("deny")
	Data.respect -= randi_range(given_respect_min, given_respect_min)


func get_resume() -> String:
	return character.resume


func get_social_networks() -> Array[String]:
	return character.social_networks


func get_character() -> Character:
	return character
