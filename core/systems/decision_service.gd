## Применяет решения игрока, не связывая Car с глобальным состоянием. 
class_name DecisionService extends RefCounted


## Применяет решение по машине; false — состояние не изменено
func apply_decision(car: Car, accepted: bool, game_state: GameState) -> bool:
	if car == null or not is_instance_valid(car):
		push_warning('DecisionService: машина отсутствует.')
		return false
	if game_state == null:
		push_warning('DecisionService: не передано хранилище состояния.')
		return false
	var effect: DecisionEffect = car.calculate_decision(accepted) ## Рассчитанные изменения
	if effect == null:
		return false
	if not game_state.apply_delta(effect.money, effect.respect):
		return false
	car.play_decision(accepted)
	return true
