## Централизует отображение игровых экранов и состояние кнопок. 
## Не знает о структуре сцены: все узлы приходят через UIBindings. 
class_name UIController extends RefCounted

var _view: UIBindings ## Узлы интерфейса, переданные из Game


## Принимает узлы интерфейса, с которыми будет работать контроллер
func setup(bindings: UIBindings) -> void:
	_view = bindings


## Включает или выключает кнопки принятия и отказа
func set_decision_buttons_enabled(enabled: bool) -> void:
	if _view == null:
		return
	for button in _view.decision_buttons:
		if not is_instance_valid(button):
			continue
		if enabled:
			button.on()
		else:
			button.off()


## Показывает резюме посетителя
func show_car_resume(car: Car) -> void:
	if _view != null and is_instance_valid(_view.resume):
		_view.resume.call('set_text', car.get_resume())


## Показывает текст события и скрывает кнопку продолжения
func show_event(event: Event) -> void:
	if _view == null:
		return
	if is_instance_valid(_view.event_label):
		_view.event_label.text = event.event_text
	if is_instance_valid(_view.event_continue_button):
		_view.event_continue_button.hide()
	if is_instance_valid(_view.main_ui):
		_view.main_ui.show()
	if is_instance_valid(_view.event_panel):
		_view.event_panel.show()
	if is_instance_valid(_view.event_card):
		_view.event_card.show()


## Открывает панель социальных сетей посетителя
func open_social_networks(car: Car) -> void:
	if _view == null:
		return
	if not is_instance_valid(_view.main_ui) or not is_instance_valid(_view.web):
		return
	if not is_instance_valid(_view.back_button):
		return
	_view.main_ui.show()
	_view.back_button.show()
	_view.web.call('set_text', car.get_social_networks())


## Подготавливает интерфейс к диалогу
func prepare_dialog() -> void:
	if _view == null:
		return
	if is_instance_valid(_view.main_ui):
		_view.main_ui.show()
	if is_instance_valid(_view.back_button):
		_view.back_button.hide()


## Скрывает панели после того, как игрок продолжил игру
func hide_for_continue() -> void:
	if _view == null:
		return
	if is_instance_valid(_view.web):
		_view.web.hide()
	if is_instance_valid(_view.dialog):
		_view.dialog.hide()
	if is_instance_valid(_view.main_ui):
		_view.main_ui.hide()


## Показывает финальный экран
func show_end_screen() -> void:
	if _view == null:
		return
	if is_instance_valid(_view.main_ui):
		_view.main_ui.show()
	if is_instance_valid(_view.end_label):
		_view.end_label.show()
	if is_instance_valid(_view.event_continue_button):
		_view.event_continue_button.hide()
