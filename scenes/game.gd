## В этом скрипте хранится основной игровой цикл
extends Node3D

@export var player: Player ## Игрок
@export var cars: Array[Car] ## Список автомобилей по очереди

@export var ui: Control ## Пользовательский интерфейс
@export var resume: Node3D ## Узел для отображения резюме кандидата
@export var web: Panel ## Панель для отображения социальных сетей кандидата
@export var dialog: Panel ## диалог с кандидатом

var index: int = -1 ## Номер текущей машины. В начале машины нет, поэтому -1
var current_car: Car ## Текущая машина


func _ready() -> void: ## Настройка сцены и запуск игрового цикла
	next()


func next() -> void: ## Вызывает следующую машину
	index += 1
	if index > len(cars) - 1:
		end_game()
		return
	var car: Car = cars[index]
	current_car = car
	car.start()
	setup(car)


func setup(car: Car) -> void: ## Настраивает машину
	resume.set_text(car.get_resume())


func accert() -> void: ## Принимает машину
	if not current_car:
		return
	current_car.to_accept()
	next()


func deny() -> void: ## Отклоняет машину
	if not current_car:
		return
	current_car.deny()
	next()


func open_web() -> void: ## Откроет социальные сети кандидата
	if not current_car:
		return
	ui.show()
	web.set_text(current_car.get_social_networks())
	player.player_stop()


func start_dialog() -> void: ## Начнёт диалог
	if not current_car or not current_car.get_dialogs():
		return
	ui.show()
	player.player_stop()
	dialog.start_dialog(current_car.get_dialogs(), current_car.get_start_phrase())


func player_continue() -> void: ## Игрок покидает ui и продолжает игру
	web.hide()
	dialog.hide()
	ui.hide()
	player.player_continue()


func end_game() -> void: ## Заканичвает игру
	player.player_stop()
	ui.show()
	$UI/Label.show()
	$UI/Button.hide()
