
extends Control

@export var container: CircularContainer
@export var choice_visual: ChoiceVisual

@export_category("Настройки выбора")
@export var choice_font_size: int = 8
@export var selected_color: Color = Color.YELLOW
@export var normal_color: Color = Color.WHITE

var character: Character
var curent_dialog: LinearDialog
var id: int = -1 ## Текущий номер реплики

var end: bool = true
var current_choice: int = 0


func _ready() -> void:
	choice_visual.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if not choice_visual.choice_changed.is_connected(set_choice):
		choice_visual.choice_changed.connect(set_choice)


func start_dialog(target_character: Character) -> void:
	if not end or target_character.dialog_end:
		return

	end = false
	target_character.dialog_end = true
	character = target_character

	choice_visual.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	show()
	get_parent().show()
	play(character.start_dialog)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_mouse"):
		if choice_visual.visible:
			confirm_choice()
		elif curent_dialog and curent_dialog.replicas:
			next()


func play(dialog_name: String) -> void:
	var dialog := _find_dialog(dialog_name)

	if not dialog:
		push_error("Диалог с именем '%s' не найден у персонажа." % dialog_name)
		return

	clear_choises()
	choice_visual.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	id = -1
	curent_dialog = dialog


func next() -> void:
	if not curent_dialog:
		return

	id += 1

	if id >= curent_dialog.replicas.size():
		var choise_name := curent_dialog.next_choise
		$Label.text = ""

		show_choises(choise_name)
		curent_dialog = null
		return

	$Label.text = curent_dialog.replicas[id]


func show_choises(choise_name: String) -> void:
	clear_choises()

	if choise_name.is_empty():
		_finish_dialog()
		return

	var choise := _find_choise(choise_name)

	if not choise:
		push_error("Выбор с именем '%s' не найден у персонажа." % choise_name)
		_finish_dialog()
		return

	if choise.choises.is_empty():
		_finish_dialog()
		return

	current_choice = 0

	for answer_text in choise.choises:
		var choice_label := Label.new()

		choice_label.text = answer_text
		choice_label.add_theme_font_size_override("font_size", choice_font_size)
		choice_label.set_meta("dialog_name", choise.choises[answer_text])

		container.add_child(choice_label)

	update_choice_visual()

	choice_visual.reset_choice()
	choice_visual.show()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func confirm_choice() -> void:
	var children = container.get_children()

	if current_choice < 0 or current_choice >= children.size():
		return

	var selected_label = children[current_choice]
	var dialog_name: String = selected_label.get_meta("dialog_name")

	choice_visual.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	play(dialog_name)


func set_choice(choice_index: int) -> void:
	if choice_index < 0 or choice_index >= container.get_child_count():
		return

	current_choice = choice_index
	update_choice_visual()


func update_choice_visual() -> void:
	var children = container.get_children()

	for i in range(children.size()):
		var label = children[i]

		if i == current_choice:
			label.modulate = selected_color
		else:
			label.modulate = normal_color


func _finish_dialog() -> void:
	curent_dialog = null
	clear_choises()
	$Label.text = ""

	choice_visual.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	end = true
	get_parent().get_parent().player_continue()


func _find_dialog(dialog_name: String) -> LinearDialog:
	for dialog in character.dialogs:
		if dialog.name == dialog_name:
			return dialog
	return null


func _find_choise(choise_name: String) -> Choise:
	for choise in character.choises:
		if choise.name == choise_name:
			return choise
	return null


func clear_choises() -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
