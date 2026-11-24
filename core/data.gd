## Единая точка изменения глобального игрового состояния. 
class_name GameState extends Node

signal state_changed(money_delta: int, respect_delta: int)

const MAX_DELTA: int = 1000000 ## Максимальное по модулю изменение за одну операцию
const MAX_VALUE: int = 100000000 ## Предел значений денег и репутации

var money: int = 0 ## Текущее количество денег
var respect: int = 0 ## Текущая репутация


## Применяет оба изменения атомарно: либо оба, либо ни одного
func apply_delta(money_delta: int, respect_delta: int) -> bool:
	if absi(money_delta) > MAX_DELTA or absi(respect_delta) > MAX_DELTA:
		push_warning('GameState: операция отклонена — изменение превышает допустимый предел.')
		return false

	var next_money: int = money + money_delta ## Деньги после операции
	var next_respect: int = respect + respect_delta ## Репутация после операции
	if next_money < 0:
		push_warning('GameState: операция отклонена — баланс не может стать отрицательным.')
		return false
	if next_money > MAX_VALUE or absi(next_respect) > MAX_VALUE:
		push_warning('GameState: операция отклонена — значение выходит за допустимый предел.')
		return false

	money = next_money
	respect = next_respect
	state_changed.emit(money_delta, respect_delta)
	return true


## Задаёт начальные значения; значения вне допустимых пределов ограничиваются
func reset(start_money: int = 0, start_respect: int = 0) -> void:
	money = clampi(start_money, 0, MAX_VALUE)
	respect = clampi(start_respect, -MAX_VALUE, MAX_VALUE)
	state_changed.emit(money, respect)
