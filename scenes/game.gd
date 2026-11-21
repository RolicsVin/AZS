## В этом скрипте хранится основной игровой цикл
extends Node3D


@export var cars: Array[Car] ## Список автомобилей по очереди

@export var ui: Control ## Пользовательский интерфейс
@export var resume: Node3D ## Узел для отображения резюме кандидата
@export var web: Panel ## Панель для отображения социальных сетей кандидата
@export var dialog: Control ## Диалог с кандидатом
@export var back_button: Button

@onready var accert_button: AreaButon = $Buttons/Accert
@onready var deny_button: AreaButon = $Buttons/Deny

var index: int = -1 ## Номер текущей машины. В начале машины нет, поэтому -1
var current_car: Car ## Текущая машина


func _ready() -> void:
	_set_decision_buttons_enabled(false)

	if dialog != null and dialog.has_signal("dialog_finished"):
		var finished_callback := Callable(self, "_on_dialog_finished")
		if not dialog.is_connected("dialog_finished", finished_callback):
			dialog.connect("dialog_finished", finished_callback)

	next()


func next() -> void:
	# Разрешение на принятие решения не должно переноситься на следующего персонажа.
	_set_decision_buttons_enabled(false)

	index += 1

	if index > cars.size() - 1:
		end_game()
		return

	var car: Car = cars[index]
	current_car = car
	car.start()
	setup(car)


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


func end_game() -> void:
	ui.show()
	$UI/Label.show()
	$UI/Button.hide()
