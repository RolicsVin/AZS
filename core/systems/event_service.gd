## Проверяет событие и применяет его эффект, не управляя интерфейсом.
class_name EventService extends RefCounted

func apply_event(event: Event, game_state: Node) -> bool:
	if event == null or not is_instance_valid(event):
		push_warning("EventService: событие отсутствует.")
		return false
	if not event.validate_configuration():
		return false
	if game_state == null or not game_state.has_method("apply_delta"):
		push_warning("EventService: некорректное хранилище состояния.")
		return false
	return game_state.apply_delta(event.money, event.respect)
