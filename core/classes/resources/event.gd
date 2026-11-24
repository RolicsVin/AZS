## Данные события. Не содержит логики отображения или изменения состояния.
class_name Event extends Resource

@export_multiline var event_text: String
@export var anim_name: String = "default"
@export var money: int = 0
@export var respect: int = 0


func validate_configuration() -> bool:
	if event_text.strip_edges().is_empty():
		push_warning("Event: текст события пуст.")
		return false
	if anim_name.strip_edges().is_empty():
		push_warning("Event: не задано имя анимации.")
		return false
	return true
