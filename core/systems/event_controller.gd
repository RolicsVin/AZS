## Координирует применение эффекта события и его отображение.
class_name EventController extends RefCounted

## Сервис валидации события и применения его числового эффекта.
var event_service: EventService
## Контроллер отображения успешно обработанного события.
var ui_controller: UIController


## Назначает сервис обработки событий и контроллер отображения.
func setup(service: EventService, ui: UIController) -> void:
	event_service = service
	ui_controller = ui


## Применяет событие через EventService и показывает его через UIController только при успешном применении.
func process_event(event: Event, game_state: GameState) -> bool:
	if event_service == null or not event_service.apply_event(event, game_state):
		return false
	if ui_controller != null:
		ui_controller.show_event(event)
	return true
