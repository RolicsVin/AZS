## Централизует отображение игровых экранов и состояние кнопок.
class_name UIController extends RefCounted

var game: Node
var main_ui: Control
var resume: Node
var web: Control
var event_panel: Control
var dialog: Control
var back_button: Button
var decision_buttons: Array[AreaButon] = []
var event_label: Label
var event_continue_button: Control
var end_label: Control
var end_button: Control


func setup(game_node: Node) -> void:
	game = game_node
	main_ui = game.get("ui") as Control
	resume = game.get("resume") as Node
	web = game.get("web") as Control
	event_panel = game.get("event_panel") as Control
	dialog = game.get("dialog") as Control
	back_button = game.get("back_button") as Button
	
	var accept_button := game.get_node_or_null("Buttons/Accert") as AreaButon
	var deny_button := game.get_node_or_null("Buttons/Deny") as AreaButon
	if accept_button != null:
		decision_buttons.append(accept_button)
	if deny_button != null:
		decision_buttons.append(deny_button)
	
	event_label = game.get_node_or_null("UI/Panel/Label") as Label
	event_continue_button = game.get_node_or_null("UI/Button") as Control
	end_label = game.get_node_or_null("UI/Label") as Control
	end_button = event_continue_button


func set_decision_buttons_enabled(enabled: bool) -> void:
	for button in decision_buttons:
		if not is_instance_valid(button):
			continue
		if enabled:
			button.on()
		else:
			button.off()


func show_car_resume(car: Car) -> void:
	if is_instance_valid(resume):
		resume.call("set_text", car.get_resume())


func show_event(event: Event) -> void:
	if is_instance_valid(event_label):
		event_label.text = event.event_text
	if is_instance_valid(event_continue_button):
		event_continue_button.hide()
	if is_instance_valid(main_ui):
		main_ui.show()
	if is_instance_valid(event_panel):
		event_panel.show()
	var panel := game.get_node_or_null("UI/Panel") as Control
	if is_instance_valid(panel):
		panel.show()


func open_social_networks(car: Car) -> void:
	if not is_instance_valid(main_ui) or not is_instance_valid(web) or not is_instance_valid(back_button):
		return
	main_ui.show()
	back_button.show()
	web.call("set_text", car.get_social_networks())


func prepare_dialog() -> void:
	if is_instance_valid(main_ui):
		main_ui.show()
	if is_instance_valid(back_button):
		back_button.hide()


func hide_for_continue() -> void:
	if is_instance_valid(web):
		web.hide()
	if is_instance_valid(dialog):
		dialog.hide()
	if is_instance_valid(main_ui):
		main_ui.hide()


func show_end_screen() -> void:
	if is_instance_valid(main_ui):
		main_ui.show()
	if is_instance_valid(end_label):
		end_label.show()
	if is_instance_valid(end_button):
		end_button.hide()
