## Управляет порядком рабочих смен и элементов внутри них. 
class_name SequenceController extends RefCounted

## Смены, которые SequenceController выдаёт в порядке прохождения.
var works: Array[Work] = [] ## Смены в порядке прохождения
## Индекс смены, из которой будет выдан следующий элемент.
var work_index: int = 0 ## Индекс текущей смены
## Индекс следующего элемента в текущей смене.
var item_index: int = 0 ## Индекс следующего элемента в текущей смене
## Индекс последней выданной смены; используется для определения перехода.
var _last_work_index: int = -1 ## Индекс смены, выданной в прошлый раз


## Задаёт смены и начинает последовательность сначала
func setup(source_works: Array[Work]) -> void:
	works = source_works
	work_index = 0
	item_index = 0
	_last_work_index = -1


## Возвращает следующий элемент последовательности. 
## entered_work — вход в новую смену; changed_work — переход после первой смены.
func take_next() -> SequenceEntry:
	while work_index < works.size():
		var work: Work = works[work_index] ## Текущая смена
		if work == null:
			work_index += 1
			item_index = 0
			continue

		# Размер проверяется при каждом запросе: Work может динамически вставить Event
		if item_index >= work.sequence.size():
			work_index += 1
			item_index = 0
			continue

		var entry: SequenceEntry = SequenceEntry.new() ## Выдаваемый шаг
		entry.work = work
		entry.entered_work = _last_work_index != work_index
		entry.changed_work = entry.entered_work and _last_work_index != -1
		entry.item_index = item_index
		entry.item = work.get_sequence_item(item_index)
		_last_work_index = work_index
		item_index += 1
		return entry

	var finish: SequenceEntry = SequenceEntry.new() ## Признак конца последовательности
	finish.finished = true
	return finish
