## В этом скрипте хранится основной игровой цикл
extends Node3D

@export var works: Array[Work] ## Рабочие смены по очереди

@export var ui: Control
@export var resume: Node3D
@export var web: Panel
@export var dialog: Control
@export var back_button: Button

@onready var accert_button: AreaButon = $Buttons/Accert
@onready var deny_button: AreaButon = $Buttons/Deny

var work_index: int = 0
var item_index: int = 0
var current_car: Car
var waiting_for_event: bool = false


func _ready() -> void:
	_set_decision_buttons_enabled(false)

	if dialog != null and dialog.has_signal("dialog_finished"):
		var finished_callback := Callable(self, "_on_dialog_finished")
		if not dialog.is_connected("dialog_finished", finished_callback):
			dialog.connect("dialog_finished", finished_callback)

	next()


## Переходит к следующему элементу текущей смены.
## Элементом может быть машина или текстовое событие.
func next() -> void:
	_set_decision_buttons_enabled(false)
	current_car = null

	while work_index < works.size():
		var work: Work = works[work_index]

		if item_index >= work.sequence.size():
			work_index += 1
			item_index = 0
			continue

		var item: Variant = work.get_sequence_item(item_index)
		item_index += 1

		if item is Car:
			current_car = item as Car
			current_car.start()
			setup(current_car)
			return

		if item is Event:
			_show_event(item as Event)
			return

		push_warning("Неизвестный элемент в рабочей смене: %s" % [item])
	
	end_game()


func _show_event(event: Event) -> void:
	# События не требуют решения игрока — показываем только текст.
	waiting_for_event = true
	resume.set_text(event.event_text)
	ui.show()
	$UI/Button.show()


func setup(car: Car) -> void:
	resume.set_text(car.get_resume())


func accert() -> void:
	if not current_car or not accert_button.active:
		return
	current_car.to_accept()
	next()


func deny() -> void:
	if not current_car or not deny_button.active:
		return
	current_car.deny()
	next()


func open_web() -> void:
	if not current_car:
		return
	ui.show()
	back_button.show()
	web.set_text(current_car.get_social_networks())


func start_dialog() -> void:
	if not current_car or not current_car.character:
		return
	if current_car.character.start_dialog.is_empty():
		push_error("У персонажа не задано имя стартового диалога.")
		return
	ui.show()
	back_button.hide()
	dialog.start_dialog(current_car.get_character())


func _on_dialog_finished() -> void:
	_set_decision_buttons_enabled(true)
	player_continue()


func _set_decision_buttons_enabled(enabled: bool) -> void:
	if is_instance_valid(accert_button):
		if enabled:
			accert_button.on()
		else:
			accert_button.off()

	if is_instance_valid(deny_button):
		if enabled:
			deny_button.on()
		else:
			deny_button.off()


func player_continue() -> void:
	web.hide()
	dialog.hide()
	ui.hide()

	if waiting_for_event:
		waiting_for_event = false
		next()


func end_game() -> void:
	current_car = null
	ui.show()
	$UI/Label.show()
	$UI/Button.hide()
