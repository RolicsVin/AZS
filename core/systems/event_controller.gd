## Координирует применение эффекта события и его отображение.
class_name EventController extends RefCounted

var event_service: EventService
var ui_controller: UIController


func setup(service: EventService, ui: UIController) -> void:
	event_service = service
	ui_controller = ui


func process_event(event: Event, game_state: GameState) -> bool:
	if event_service == null or not event_service.apply_event(event, game_state):
		return false
	if ui_controller != null:
		ui_controller.show_event(event)
	return true
