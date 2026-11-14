## Класс, релизующий машину. в которой едет персонаж. 
## Содержит самого персонажа. 
class_name Car extends Node


@export var character: Character


func start(): ## Когда машина подезжает к игроку
	pass


func to_accept(): ## Пропустить машину дальше
	pass


func deny(): ## Не пропускать машину
	pass


func get_resume() -> String: ## Вернёт резюме персонажа
	return character.resume


func get_social_networks() -> Array[String]: ## Вернёт резюме персонажа
	return character.social_networks
