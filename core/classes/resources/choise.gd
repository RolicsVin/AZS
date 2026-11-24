## Данные вариантов ответа и их последствия.
class_name Choise extends Resource


@export var name: String ## Имя выбора

## Ключ — текст варианта ответа; значение — имя диалога, запускаемого при выборе.
@export var choises: Dictionary[String, String]

## Ключ — текст варианта ответа; значение — изменение репутации при его выборе.
@export var respect_rewards: Dictionary[String, int] = {}


## Проверяет соответствие наград существующим вариантам и допустимые значения репутации.
func validate_configuration() -> bool:
	for answer_text in respect_rewards:
		if not choises.has(answer_text):
			push_warning("Choise: награда указана для отсутствующего варианта '%s'." % answer_text)
			return false
		if absi(respect_rewards[answer_text]) > GameState.MAX_DELTA:
			push_warning("Choise: изменение репутации для варианта '%s' превышает допустимый предел." % answer_text)
			return false
	return true
