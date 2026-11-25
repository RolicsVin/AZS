## Данные вариантов ответа и их последствия.
class_name Choise extends Resource

@export var name: String ## Имя выбора
## Ключ - отображаемый текст варианта; значение - имя диалога назначения.
@export var choises: Dictionary[String, String]
## Ключ - имя диалога назначения (например, "agro"); значение - изменение репутации.
@export var respect_rewards: Dictionary[String, int] = {}

## Проверяет, что награды назначены существующим диалогам назначения и находятся в допустимых пределах.
func validate_configuration() -> bool:
	var target_dialogs: Dictionary = {}
	for target_dialog in choises.values():
		target_dialogs[target_dialog] = true
	for target_dialog in respect_rewards:
		if not target_dialogs.has(target_dialog):
			push_warning("Choise: награда указана для отсутствующего диалога назначения '%s'." % target_dialog)
			return false
		if absi(respect_rewards[target_dialog]) > GameState.MAX_DELTA:
			push_warning("Choise: изменение репутации для диалога '%s' превышает допустимый предел." % target_dialog)
			return false
	return true
