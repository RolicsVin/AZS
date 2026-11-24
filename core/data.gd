## Единая точка изменения глобального игрового состояния.
class_name GameState extends Node

signal state_changed(money_delta: int, respect_delta: int)

var money: int = 0
var respect: int = 0

## Применяет оба изменения атомарно.
func apply_delta(money_delta: int, respect_delta: int) -> bool:
	if typeof(money_delta) != TYPE_INT or typeof(respect_delta) != TYPE_INT:
		push_warning("GameState: некорректные типы изменений.")
		return false

	var next_money: int = money + money_delta
	var next_respect: int = respect + respect_delta
	if next_money < 0:
		push_warning("GameState: операция отклонена — баланс не может стать отрицательным.")
		return false

	money = next_money
	respect = next_respect
	state_changed.emit(money_delta, respect_delta)
	return true


func reset() -> void:
	money = 0
	respect = 0
	state_changed.emit(0, 0)
