## Данные события. Не содержит логики отображения или изменения состояния. 
class_name Event extends Resource

@export var id: String = '' ## Идентификатор события для ссылок из файла контента
@export_multiline var event_text: String ## Текст события
@export var anim_name: String = 'default' ## Имя анимации события
@export var money: int = 0 ## Изменение денег
@export var respect: int = 0 ## Изменение репутации


## Создаёт событие из словаря JSON; при ошибке дописывает сообщения в errors и возвращает null
static func from_dictionary(data: Dictionary, errors: Array[String]) -> Event:
	var problems: Array[String] = [] ## Ошибки чтения полей
	var limit: int = GameState.MAX_DELTA ## Допустимый модуль изменения
	var event: Event = Event.new() ## Создаваемое событие
	event.id = JsonReader.read_string(data, 'id', '', true, problems)
	event.event_text = JsonReader.read_string(data, 'text', '', true, problems)
	event.anim_name = JsonReader.read_string(data, 'animation', 'default', false, problems)
	event.money = JsonReader.read_int(data, 'money', 0, -limit, limit, problems)
	event.respect = JsonReader.read_int(data, 'respect', 0, -limit, limit, problems)
	if event.anim_name.strip_edges().is_empty():
		event.anim_name = 'default'
	if not problems.is_empty():
		errors.append_array(problems)
		return null
	return event


## Проверяет корректность полей события
func validate_configuration() -> bool:
	if event_text.strip_edges().is_empty():
		push_warning('Event: текст события пуст.')
		return false
	if anim_name.strip_edges().is_empty():
		push_warning('Event: не задано имя анимации.')
		return false
	if absi(money) > GameState.MAX_DELTA or absi(respect) > GameState.MAX_DELTA:
		push_warning('Event: эффект события превышает допустимый предел.')
		return false
	return true
