## В этом скрипте хранится основной игровой цикл
extends Node3D

@export var player: Player ## Игрок
@export var cars: Array[Car] ## Список автомобилей по очереди

@export var ui: Control ## Пользовательский интерфейс
@export var resume: Node3D ## Узел для отображения резюме кандидата
@export var web: Panel ## Панель для отображения социальных сетей кандидата
@export var dialog: Panel ## диалог с кандидатом

var index: int = -1 ## Номер текущей машины. В начале машины нет, поэтому -1


func _ready() -> void: ## Настройка сцены
	next()


func next() -> void: ## Вызывает следующую машину
	index = clamp(index + 1, 0, len(cars) - 1) # Учитываем, что индекс может выйти за размер массива
	var car: Car = cars[index]
	car.start()
	setup(car)


func setup(car: Car) -> void: ## Настраивает машину
	resume.set_text(car.get_resume())
	web.set_text(car.get_social_networks())


func _process(delta: float) -> void: ## Игровой цикл
	pass


func open_web(): ## Откроет социальные сети кандидата
	pass


func start_dialog(): ## Начнёт диалог
	pass


func player_continue(): ## Игрок покидает ui и продолжает игру
	web.hide()
	dialog.hide()
	ui.hide()
	player.player_continue()
