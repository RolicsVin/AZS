## Результат расчёта решения игрока: изменения денег и репутации. 
## Заменяет словарь с ключами-строками, чтобы опечатки ловились при разборе скрипта. 
class_name DecisionEffect extends RefCounted

var money: int = 0 ## Изменение денег
var respect: int = 0 ## Изменение репутации


## Создаёт эффект с заданными изменениями
func _init(money_delta: int = 0, respect_delta: int = 0) -> void:
	money = money_delta
	respect = respect_delta
