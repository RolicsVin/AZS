## Проверяет событие и применяет его эффект, не управляя интерфейсом. 
class_name EventService extends RefCounted


## Применяет эффект события; false — событие некорректно или состояние не изменено
func apply_event(event: Event, game_state: GameState) -> bool:
	if event == null or not is_instance_valid(event):
		push_warning('EventService: событие отсутствует.')
		return false
	if not event.validate_configuration():
		return false
	if game_state == null:
		push_warning('EventService: не передано хранилище состояния.')
		return false
	return game_state.apply_delta(event.money, event.respect)
