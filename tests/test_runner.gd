## Автотесты архитектуры: запускаются из консоли без игровой сцены. 
## Команда: godot --headless --path . --script res://tests/test_runner.gd 
## Перед первым запуском выполните: godot --headless --path . --import 
extends SceneTree

const BEFORE_PATH: String = 'res://docs/examples/content.before.json' ## Исходный контент
const AFTER_PATH: String = 'res://docs/examples/content.after.json' ## Контент с новым событием
const INVALID_PATH: String = 'res://docs/examples/content.invalid.json' ## Контент с ошибками

var _passed: int = 0 ## Число пройденных проверок
var _failed: int = 0 ## Число проваленных проверок


func _init() -> void:
	_test_game_state()
	_test_loader_valid_file()
	_test_loader_broken_text()
	_test_loader_invalid_file()
	_test_applier_on_invalid_file()
	_test_services_keep_state()
	_test_sequence_controller()
	_test_extension_through_data()
	print('ИТОГ: пройдено %d, провалено %d' % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


## Записывает результат одной проверки
func _check(condition: bool, title: String) -> void:
	if condition:
		_passed += 1
		print('  [OK]   %s' % title)
	else:
		_failed += 1
		print('  [FAIL] %s' % title)


## Создаёт корректное событие для тестов
func _make_event(event_id: String, money: int, respect: int) -> Event:
	var event: Event = Event.new() ## Тестовое событие
	event.id = event_id
	event.event_text = 'Тестовое событие'
	event.money = money
	event.respect = respect
	return event


## Создаёт смену с заданным числом событий-заглушек
func _make_work(work_name: String, items_count: int) -> Work:
	var work: Work = Work.new() ## Тестовая смена
	work.name = work_name
	for index in items_count:
		work.sequence.append(_make_event('stub_%d' % index, 0, 0))
	return work


## GameState: атомарность и защита от выхода за пределы
func _test_game_state() -> void:
	print('GameState')
	var state: GameState = GameState.new() ## Проверяемое хранилище
	_check(state.apply_delta(10, 5), 'допустимое изменение применяется')
	_check(state.money == 10 and state.respect == 5, 'значения изменились')
	_check(not state.apply_delta(-50, 7), 'уход баланса в минус отклоняется')
	_check(state.money == 10 and state.respect == 5, 'при отказе ничего не изменилось')
	_check(not state.apply_delta(GameState.MAX_DELTA + 1, 0), 'слишком большая дельта отклонена')
	state.reset(GameState.MAX_VALUE, 0)
	_check(not state.apply_delta(1, 0), 'переполнение значения отклоняется')
	_check(state.money == GameState.MAX_VALUE, 'после отказа по пределу значение прежнее')
	state.reset(-5, 3)
	_check(state.money == 0 and state.respect == 3, 'reset ограничивает начальные значения')
	state.free()


## ContentLoader: корректный файл
func _test_loader_valid_file() -> void:
	print('ContentLoader: корректный файл')
	var bundle: ContentBundle = ContentLoader.new().load_file(BEFORE_PATH) ## Результат загрузки
	_check(bundle.is_loaded, 'файл загружен')
	_check(bundle.errors.is_empty(), 'ошибок нет')
	_check(bundle.events.size() == 1 and bundle.events.has('local_newspaper'), 'событие прочитано')
	_check(bundle.insertions.size() == 1, 'вставка прочитана')


## ContentLoader: файл отсутствует, пустой или повреждён
func _test_loader_broken_text() -> void:
	print('ContentLoader: повреждённые данные')
	var loader: ContentLoader = ContentLoader.new() ## Проверяемый загрузчик
	var missing: ContentBundle = loader.load_file('res://content/no_such_file.json')
	_check(not missing.is_loaded and not missing.errors.is_empty(), 'нет файла — ошибка')
	var empty: ContentBundle = loader.parse_text('')
	_check(not empty.is_loaded and not empty.errors.is_empty(), 'пустой текст — ошибка')
	var syntax: ContentBundle = loader.parse_text('{ "format_version": ')
	_check(not syntax.is_loaded and not syntax.errors.is_empty(), 'ошибка синтаксиса JSON')
	var array_root: ContentBundle = loader.parse_text('[]')
	_check(not array_root.is_loaded, 'корень-массив отклоняется')
	var wrong_version: ContentBundle = loader.parse_text('{ "format_version": 2 }')
	_check(not wrong_version.is_loaded, 'неизвестная версия отклоняется')
	var minimal: ContentBundle = loader.parse_text('{ "format_version": 1 }')
	_check(minimal.is_loaded and minimal.errors.is_empty(), 'минимальный файл допустим')
	_check(minimal.events.is_empty() and minimal.insertions.is_empty(), 'пустой контент допустим')
	var bad_type: ContentBundle = loader.parse_text('{ "format_version": 1, "events": 5 }')
	_check(bad_type.events.is_empty() and bad_type.errors.size() == 1, 'events не массив — ошибка')


## ContentLoader: файл с набором ошибочных и граничных значений
func _test_loader_invalid_file() -> void:
	print('ContentLoader: файл с ошибками')
	var bundle: ContentBundle = ContentLoader.new().load_file(INVALID_PATH) ## Результат загрузки
	_check(bundle.is_loaded, 'файл с ошибками в записях всё равно загружается')
	_check(bundle.events.size() == 1 and bundle.events.has('ok_event'), 'оставлено верное событие')
	_check(bundle.insertions.size() == 3, 'сохранены только корректные вставки')
	_check(bundle.errors.size() == 10, 'каждая проблема описана отдельным сообщением')
	_check(bundle.start_money == 0, 'неверное start_money заменено значением по умолчанию')
	_check(bundle.transition_duration < 0.0, 'неверная длительность затемнения не применяется')
	_check(bundle.event_gap_min == 2 and bundle.event_gap_max == 3, 'неверный диапазон сброшен')


## ContentApplier: вставки с граничными индексами и неизвестной сменой
func _test_applier_on_invalid_file() -> void:
	print('ContentApplier: граничные вставки')
	var bundle: ContentBundle = ContentLoader.new().load_file(INVALID_PATH) ## Набор с ошибками
	var work: Work = _make_work('Work', 3) ## Смена для вставок
	var works: Array[Work] = [work] ## Смены игры
	var skipped: Array[String] = ContentApplier.new().apply(bundle, works) ## Пропущенные вставки
	_check(skipped.size() == 1, 'вставка в несуществующую смену пропущена и описана')
	_check(work.sequence.size() == 5, 'остальные вставки применены')
	var inserted: Event = work.sequence[1] as Event ## Событие по индексу 1
	_check(inserted != null and inserted.id == 'ok_event', 'вставка по индексу попала на место')
	var appended: Event = work.sequence[work.sequence.size() - 1] as Event ## Последний элемент
	_check(appended != null and appended.id == 'ok_event', 'индекс за концом — вставка в конец')
	work.free()


## Сервисы: отказ не меняет состояние
func _test_services_keep_state() -> void:
	print('EventService и DecisionService: состояние не разрушается')
	var state: GameState = GameState.new() ## Проверяемое хранилище
	state.reset(10, 0)
	var events: EventService = EventService.new() ## Сервис событий
	_check(not events.apply_event(_make_event('cost', -50, 3), state), 'дорогое событие отклонено')
	_check(state.money == 10 and state.respect == 0, 'состояние после отказа прежнее')
	_check(not events.apply_event(Event.new(), state), 'событие без текста отклонено')
	_check(not events.apply_event(null, state), 'null вместо события отклонён')
	_check(events.apply_event(_make_event('gain', 5, 1), state), 'корректное событие применено')
	_check(state.money == 15 and state.respect == 1, 'состояние изменилось ровно на эффект')

	var decisions: DecisionService = DecisionService.new() ## Сервис решений
	var car: Car = Car.new() ## Машина без персонажа
	_check(not decisions.apply_decision(car, true, state), 'машина без Character отклонена')
	_check(state.money == 15 and state.respect == 1, 'состояние после отказа прежнее')
	car.character = Character.new()
	_check(decisions.apply_decision(car, true, state), 'решение с корректной машиной применено')
	_check(state.money >= 25 and state.money <= 30, 'награда в заданном диапазоне')
	car.free()
	state.free()


## SequenceController: порядок элементов и признаки смены
func _test_sequence_controller() -> void:
	print('SequenceController')
	var first: Work = _make_work('First', 2) ## Первая смена
	var second: Work = _make_work('Second', 1) ## Вторая смена
	var works: Array[Work] = [first, second] ## Смены игры
	var controller: SequenceController = SequenceController.new() ## Проверяемый контроллер
	controller.setup(works)
	var entry: SequenceEntry = controller.take_next() ## Очередной шаг
	_check(entry.entered_work and not entry.changed_work, 'первый шаг: вход в смену без затемнения')
	controller.take_next()
	entry = controller.take_next()
	_check(entry.entered_work and entry.changed_work, 'вход во вторую смену помечен для затемнения')
	entry = controller.take_next()
	_check(entry.finished, 'после последнего элемента последовательность завершена')
	first.free()
	second.free()


## Расширение через данные: новое событие появляется без изменения кода
func _test_extension_through_data() -> void:
	print('Расширение через данные')
	var loader: ContentLoader = ContentLoader.new() ## Загрузчик
	var before: ContentBundle = loader.load_file(BEFORE_PATH) ## Исходные данные
	var after: ContentBundle = loader.load_file(AFTER_PATH) ## Данные с новым событием
	_check(after.errors.is_empty(), 'изменённый файл корректен')
	_check(after.events.size() == before.events.size() + 1, 'событий стало на одно больше')
	_check(after.events.has('regular_tips'), 'новое событие есть в изменённом файле')
	_check(not before.events.has('regular_tips'), 'в исходном файле его нет')

	var applier: ContentApplier = ContentApplier.new() ## Применяющий модуль
	var work_a: Work = _make_work('Work', 8) ## Смены, как в сцене game.tscn
	var work_b: Work = _make_work('Work2', 4)
	var works_before: Array[Work] = [work_a, work_b]
	applier.apply(before, works_before)
	_check(work_b.sequence.size() == 4, 'до изменения Work2 не менялась')
	var work_c: Work = _make_work('Work', 8)
	var work_d: Work = _make_work('Work2', 4)
	var works_after: Array[Work] = [work_c, work_d]
	applier.apply(after, works_after)
	_check(work_d.sequence.size() == 5, 'после изменения в Work2 появился элемент')
	var added: Event = work_d.sequence[2] as Event ## Новое событие
	_check(added != null and added.id == 'regular_tips', 'новое событие стоит на заданной позиции')
	for work in [work_a, work_b, work_c, work_d]:
		work.free()
