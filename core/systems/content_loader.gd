## Читает JSON-файл контента, проверяет его и собирает ContentBundle. 
## Не изменяет игровое состояние и не обращается к сцене: ошибки данных превращаются 
## в сообщения, а некорректные элементы пропускаются. 
class_name ContentLoader extends RefCounted

const SUPPORTED_VERSION: int = 1 ## Поддерживаемая версия формата файла
const MAX_ENTRIES: int = 500 ## Предельное число событий и вставок в одном файле
const MAX_POSITION: int = 10000 ## Предельный индекс вставки в последовательность


## Читает файл по пути и возвращает проверенный набор контента
func load_file(path: String) -> ContentBundle:
	if not FileAccess.file_exists(path):
		var missing: ContentBundle = ContentBundle.new() ## Пустой результат с ошибкой
		missing.errors.append('Файл контента не найден: %s' % path)
		return missing
	var file: FileAccess = FileAccess.open(path, FileAccess.READ) ## Открытый файл
	if file == null:
		var unreadable: ContentBundle = ContentBundle.new() ## Пустой результат с ошибкой
		unreadable.errors.append('Не удалось открыть файл контента: %s' % path)
		return unreadable
	return parse_text(file.get_as_text())


## Разбирает текст JSON и возвращает проверенный набор контента
func parse_text(json_text: String) -> ContentBundle:
	var bundle: ContentBundle = ContentBundle.new() ## Результат разбора
	var parser: JSON = JSON.new() ## Парсер JSON
	if parser.parse(json_text) != OK:
		var line: int = parser.get_error_line() ## Строка с синтаксической ошибкой
		var reason: String = parser.get_error_message() ## Описание ошибки
		bundle.errors.append('Некорректный JSON, строка %d: %s' % [line, reason])
		return bundle
	if typeof(parser.data) != TYPE_DICTIONARY:
		bundle.errors.append('Корень файла контента должен быть объектом.')
		return bundle
	var root: Dictionary = parser.data ## Корневой объект файла
	if not _has_supported_version(root, bundle):
		return bundle
	bundle.is_loaded = true
	_read_settings(root.get('settings', {}), bundle)
	_read_events(root.get('events', []), bundle)
	_read_insertions(root.get('insertions', []), bundle)
	return bundle


## Проверяет поле format_version; при неверной версии файл не используется
func _has_supported_version(root: Dictionary, bundle: ContentBundle) -> bool:
	var problems: Array[String] = [] ## Ошибки чтения версии
	var version: int = JsonReader.read_int(root, 'format_version', -1, 0, 1000000, problems)
	if not problems.is_empty() or version != SUPPORTED_VERSION:
		bundle.errors.append(
			'Не задана или не поддерживается версия формата, нужна %d.' % SUPPORTED_VERSION
		)
		return false
	return true


## Читает числовые настройки; неверное значение заменяется значением по умолчанию
func _read_settings(raw: Variant, bundle: ContentBundle) -> void:
	if typeof(raw) != TYPE_DICTIONARY:
		bundle.errors.append('settings: ожидался объект.')
		return
	var settings: Dictionary = raw ## Объект настроек
	var problems: Array[String] = [] ## Ошибки чтения настроек
	var limit: int = GameState.MAX_VALUE ## Предел начальных значений
	bundle.start_money = JsonReader.read_int(settings, 'start_money', 0, 0, limit, problems)
	bundle.start_respect = JsonReader.read_int(
		settings, 'start_respect', 0, -limit, limit, problems
	)
	bundle.transition_duration = JsonReader.read_float(
		settings, 'transition_duration', -1.0, 0.0, 3.0, problems
	)
	bundle.event_gap_min = JsonReader.read_int(settings, 'event_gap_min', 2, 1, 10, problems)
	bundle.event_gap_max = JsonReader.read_int(settings, 'event_gap_max', 3, 1, 10, problems)
	if bundle.event_gap_min > bundle.event_gap_max:
		problems.append('event_gap_min не может быть больше event_gap_max.')
		bundle.event_gap_min = 2
		bundle.event_gap_max = 3
	_append_prefixed(bundle, 'settings', problems)


## Читает и проверяет события; некорректные и повторяющиеся записи пропускаются
func _read_events(raw: Variant, bundle: ContentBundle) -> void:
	if typeof(raw) != TYPE_ARRAY:
		bundle.errors.append('events: ожидался массив.')
		return
	var items: Array = raw ## Записи событий из файла
	if items.size() > MAX_ENTRIES:
		bundle.errors.append('events: записей больше %d, лишние отброшены.' % MAX_ENTRIES)
	for index in mini(items.size(), MAX_ENTRIES):
		var prefix: String = 'events[%d]' % index ## Префикс сообщений об ошибках
		if typeof(items[index]) != TYPE_DICTIONARY:
			bundle.errors.append('%s: ожидался объект.' % prefix)
			continue
		var problems: Array[String] = [] ## Ошибки чтения записи
		var event: Event = Event.from_dictionary(items[index], problems) ## Созданное событие
		if event == null:
			_append_prefixed(bundle, prefix, problems)
			continue
		if bundle.events.has(event.id):
			bundle.errors.append('%s: повторяется id «%s», запись пропущена.' % [prefix, event.id])
			continue
		bundle.events[event.id] = event


## Читает и проверяет вставки; запись со ссылкой на неизвестное событие пропускается
func _read_insertions(raw: Variant, bundle: ContentBundle) -> void:
	if typeof(raw) != TYPE_ARRAY:
		bundle.errors.append('insertions: ожидался массив.')
		return
	var items: Array = raw ## Записи вставок из файла
	if items.size() > MAX_ENTRIES:
		bundle.errors.append('insertions: записей больше %d, лишние отброшены.' % MAX_ENTRIES)
	for index in mini(items.size(), MAX_ENTRIES):
		var prefix: String = 'insertions[%d]' % index ## Префикс сообщений об ошибках
		if typeof(items[index]) != TYPE_DICTIONARY:
			bundle.errors.append('%s: ожидался объект.' % prefix)
			continue
		var data: Dictionary = items[index] ## Запись вставки
		var problems: Array[String] = [] ## Ошибки чтения записи
		var work_name: String = JsonReader.read_string(data, 'work', '', true, problems)
		var event_id: String = JsonReader.read_string(data, 'event', '', true, problems)
		var sequence_index: int = JsonReader.read_int(
			data, 'position', -1, -1, MAX_POSITION, problems
		)
		if problems.is_empty() and not bundle.events.has(event_id):
			problems.append('неизвестное событие «%s»' % event_id)
		if not problems.is_empty():
			_append_prefixed(bundle, prefix, problems)
			continue
		var insertion: ContentBundle.Insertion = ContentBundle.Insertion.new() ## Новая вставка
		insertion.work_name = work_name
		insertion.sequence_index = sequence_index
		insertion.event = bundle.events[event_id]
		bundle.insertions.append(insertion)


## Добавляет сообщения в общий список с префиксом места ошибки
func _append_prefixed(bundle: ContentBundle, prefix: String, problems: Array[String]) -> void:
	for problem in problems:
		bundle.errors.append('%s: %s' % [prefix, problem])
