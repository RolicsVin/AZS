## Описание персонажа. Прогресс прохождения хранится вне Resource.
class_name Character extends Resource

@export_multiline var resume: String
@export_multiline var social_networks: Array[String]
@export var start_dialog: String
## Правила альтернативного стартового диалога. Проверяются сверху вниз.
@export var start_dialog_rules: Array[StartDialogRule] = []
@export var dialogs: Array[LinearDialog]
@export var choises: Array[Choise]

@export_group("События")
@export var deny_events: Array[Event] = []
@export var accert_events: Array[Event] = []


## Возвращает первый стартовый диалог, условие которого совпало; иначе стандартный.
func get_start_dialog(game_state: GameState) -> String:
	if game_state != null:
		for rule in start_dialog_rules:
			if rule != null and game_state.get_flag(rule.flag_name) == rule.expected_value:
				return rule.dialog_name
	return start_dialog


func validate_configuration() -> bool:
	if start_dialog.strip_edges().is_empty():
		push_warning("Character: не задан стартовый диалог.")
		return false
	var dialog_names: Dictionary = {}
	for item in dialogs:
		if item == null or item.name.strip_edges().is_empty() or dialog_names.has(item.name):
			push_warning("Character: пустой ресурс или повторяющееся имя диалога.")
			return false
		dialog_names[item.name] = true
	if not dialog_names.has(start_dialog):
		push_warning("Character: стартовый диалог '%s' не найден." % start_dialog)
		return false
	for rule in start_dialog_rules:
		if rule == null or not rule.validate_configuration(dialog_names):
			return false
	var choice_names: Dictionary = {}
	for choice in choises:
		if choice == null or choice.name.strip_edges().is_empty() or choice_names.has(choice.name):
			push_warning("Character: пустой ресурс или повторяющееся имя выбора.")
			return false
		if not choice.validate_configuration():
			return false
		choice_names[choice.name] = true

	for dialog in dialogs:
		if not dialog.next_choise.is_empty() and not choice_names.has(dialog.next_choise):
			push_warning("Character: выбор '%s' не найден." % dialog.next_choise)
			return false
	for choice in choises:
		for target_dialog in choice.choises.values():
			if not dialog_names.has(target_dialog):
				push_warning("Character: диалог назначения '%s' не найден." % target_dialog)
				return false
	return true
