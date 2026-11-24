## Единая точка изменения глобального игрового состояния.
class_name GameState extends Node

signal state_changed(money_delta: int, respect_delta: int)
signal fuel_changed(new_fuel: int)

const MAX_DELTA: int = 1000000 ## Максимальное по модулю изменение за одну операцию
const MAX_VALUE: int = 100000000 ## Предел значений денег, репутации и топлива

var money: int = 0 ## Текущее количество денег
var respect: int = 0 ## Текущая репутация
var fuel: int = 100 ## Текущий запас бензина

## Применяет изменения атомарно: либо все показатели обновляются, либо ни один.
func apply_delta(money_delta: int, respect_delta: int, fuel_delta: int = 0) -> bool:
	if absi(money_delta) > MAX_DELTA or absi(respect_delta) > MAX_DELTA or absi(fuel_delta) > MAX_DELTA:
		push_warning('GameState: операция отклонена — изменение превышает допустимый предел.')
		return false
	
	var next_money: int = money + money_delta ## Деньги после операции
	var next_respect: int = respect + respect_delta ## Репутация после операции
	var next_fuel: int = fuel + fuel_delta ## Запас топлива после операции
	if next_money < 0 or next_fuel < 0:
		push_warning('GameState: операция отклонена — деньги и топливо не могут стать отрицательными.')
		return false
	if next_money > MAX_VALUE or absi(next_respect) > MAX_VALUE or next_fuel > MAX_VALUE:
		push_warning('GameState: операция отклонена — значение выходит за допустимый предел.')
		return false

	money = next_money
	respect = next_respect
	fuel = next_fuel
	state_changed.emit(money_delta, respect_delta)
	if fuel_delta != 0:
		fuel_changed.emit(fuel)
	return true


## Задаёт начальные значения; значения вне допустимых пределов ограничиваются.
func reset(start_money: int = 0, start_respect: int = 0, start_fuel: int = 100) -> void:
	money = clampi(start_money, 0, MAX_VALUE)
	respect = clampi(start_respect, -MAX_VALUE, MAX_VALUE)
	fuel = clampi(start_fuel, 0, MAX_VALUE)
	state_changed.emit(money, respect)
	fuel_changed.emit(fuel)
