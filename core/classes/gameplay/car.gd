## Класс, релизующий машину. в которой едет персонаж. 
## Содержит самого персонажа. 
class_name Car extends Node3D


@export var character: Character
@export var anim: AnimationPlayer


func start(): ## Когда машина подезжает к игроку
	show()
	anim.play('start')


func to_accept(): ## Пропустить машину дальше
	anim.play('accept')


func deny(): ## Не пропускать машину
	anim.play('deny')


func get_resume() -> String: ## Вернёт резюме персонажа
	return character.resume


func get_social_networks() -> Array[String]: ## Вернёт резюме персонажа
	return character.social_networks


func get_dialogs() -> Array: ## первый элемент - диалоги(Array[LinearDialog]), второй - выборы(Array[Choise])
	return [character.dialogs, character.choises]


func get_start_phrase() -> LinearDialog:
	return character.start_dialog
