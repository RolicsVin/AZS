## Игровой объект посетителя. Отвечает за анимацию и постановку связанного события.
class_name Car extends Node3D

signal event_requested(event: Event)

@export_group("Награда за согласие")
@export var given_money_min: int = 10
@export var given_money_max: int = 15
@export var given_respect_min: int = 10
@export var given_respect_max: int = 15
@export var character: Character
@export var anim: AnimationPlayer

func start() -> void:
	show()
	if is_instance_valid(anim) and anim.has_animation("start"):
		anim.play("start")

func validate_configuration() -> bool:
	if character == null:
		push_warning("Car '%s': не назначен Character." % name)
		return false
	if given_money_min < 0 or given_money_max < given_money_min:
		push_warning("Car '%s': некорректный диапазон денег." % name)
		return false
	if given_respect_min < 0 or given_respect_max < given_respect_min:
		push_warning("Car '%s': некорректный диапазон репутации." % name)
		return false
	return true

## Возвращает эффект без изменения состояния; null — данные машины некорректны
func calculate_decision(accepted: bool) -> DecisionEffect:
	if not validate_configuration():
		return null
	if accepted:
		return DecisionEffect.new(
			randi_range(given_money_min, given_money_max),
			randi_range(given_respect_min, given_respect_max)
		)
	return DecisionEffect.new(0, -randi_range(given_respect_min, given_respect_max))

## Вызывается после успешного применения эффекта системой решений.
func play_decision(accepted: bool) -> void:
	if is_instance_valid(anim):
		var animation_name := "accept" if accepted else "deny"
		if anim.has_animation(animation_name):
			anim.play(animation_name)
	var events: Array[Event] = character.accert_events if accepted else character.deny_events
	_add_random_event(events)

func _add_random_event(events: Array[Event]) -> void:
	if events.is_empty():
		return
	var event: Event = events.pick_random()
	if event == null or not event.validate_configuration():
		return
	event_requested.emit(event)

func get_resume() -> String:
	return character.resume if character != null else ""

func get_social_networks() -> Array[String]:
	return character.social_networks if character != null else []

func get_character() -> Character:
	return character
