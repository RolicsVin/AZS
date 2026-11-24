extends SceneTree
## Запуск: godot --headless --path . --script res://tests/test_game_state.gd

func _initialize() -> void:
	var state_script = load("res://core/data.gd")
	var event_script = load("res://core/classes/resources/event.gd")
	var event_service_script = load("res://core/systems/event_service.gd")
	var state = state_script.new()
	state.money = 100
	state.respect = 20

	assert(state.apply_delta(50, -3))
	assert(state.money == 150)
	assert(state.respect == 17)

	var money_before: int = state.money
	var respect_before: int = state.respect
	assert(not state.apply_delta(-1000, 500))
	assert(state.money == money_before)
	assert(state.respect == respect_before)

	var valid_event = event_script.new()
	valid_event.event_text = "Тестовое событие"
	valid_event.anim_name = "default"
	valid_event.money = 25
	valid_event.respect = 2
	var event_service = event_service_script.new()
	assert(event_service.apply_event(valid_event, state))
	assert(state.money == money_before + 25)
	assert(state.respect == respect_before + 2)

	var invalid_event = event_script.new()
	invalid_event.event_text = ""
	invalid_event.anim_name = "default"
	invalid_event.money = 999
	invalid_event.respect = 999
	money_before = state.money
	respect_before = state.respect
	assert(not event_service.apply_event(invalid_event, state))
	assert(state.money == money_before)
	assert(state.respect == respect_before)

	print("Gameplay state tests: OK")
	state.free()
	quit()
