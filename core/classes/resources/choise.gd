## Данные вариантов ответа и их последствия.
class_name Choise extends Resource

@export var name: String ## Имя выбора
## Ключ - отображаемый текст варианта; значение - имя диалога назначения.
@export var choises: Dictionary[String, String]
## Ключ - имя диалога назначения; значение - изменение репутации.
@export var respect_rewards: Dictionary[String, int] = {}
## Ключ - имя диалога назначения; значение - имя флага, который станет true при выборе.
@export var decision_flags: Dictionary[String, String] = {}

## Проверяет, что награды и флаги назначены существующим диалогам назначения.
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
	for target_dialog in decision_flags:
		if not target_dialogs.has(target_dialog):
			push_warning("Choise: флаг указан для отсутствующего диалога назначения '%s'." % target_dialog)
			return false
		if str(decision_flags[target_dialog]).strip_edges().is_empty():
			push_warning("Choise: имя флага для диалога '%s' не может быть пустым." % target_dialog)
			return false
	return true
