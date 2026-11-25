## Условие выбора альтернативного стартового диалога персонажа.
class_name StartDialogRule extends Resource

@export var flag_name: String ## Флаг мира, который проверяется
@export var expected_value: bool = true ## Ожидаемое значение флага
@export var dialog_name: String ## Диалог, запускаемый при выполнении условия


## Проверяет обязательные поля и наличие целевого диалога у персонажа.
func validate_configuration(dialog_names: Dictionary) -> bool:
	if flag_name.strip_edges().is_empty():
		push_warning("StartDialogRule: не задано имя флага.")
		return false
	if dialog_name.strip_edges().is_empty() or not dialog_names.has(dialog_name):
		push_warning("StartDialogRule: целевой диалог '%s' не найден." % dialog_name)
		return false
	return true
