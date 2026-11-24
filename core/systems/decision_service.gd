## Применяет решения игрока, не связывая Car с глобальным состоянием.
class_name DecisionService extends RefCounted


func apply_decision(car: Car, accepted: bool, game_state: Node) -> bool:
	if car == null or not is_instance_valid(car):
		push_warning("DecisionService: машина отсутствует.")
		return false
	if game_state == null or not game_state.has_method("apply_delta"):
		push_warning("DecisionService: некорректное хранилище состояния.")
		return false
	var effect: Dictionary = car.calculate_decision(accepted)
	if effect.is_empty():
		return false
	if not game_state.apply_delta(int(effect.money), int(effect.respect)):
		return false
	car.play_decision(accepted)
	return true
