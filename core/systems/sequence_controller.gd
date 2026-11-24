## Управляет порядком рабочих смен и элементов внутри них.
class_name SequenceController extends RefCounted

var works: Array[Work] = []
var work_index: int = 0
var item_index: int = 0
var _last_work_index: int = -1


func setup(source_works: Array[Work]) -> void:
	works = source_works
	work_index = 0
	item_index = 0
	_last_work_index = -1


## Возвращает следующий элемент последовательности.
## entered_work — вход в новую смену; changed_work — переход после первой смены.
func take_next() -> Dictionary:
	while work_index < works.size():
		var work: Work = works[work_index]
		if work == null:
			work_index += 1
			item_index = 0
			continue
		
		# Размер проверяется при каждом запросе: Work может динамически вставить Event.
		if item_index >= work.sequence.size():
			work_index += 1
			item_index = 0
			continue
		
		var entered_work: bool = _last_work_index != work_index
		var changed_work: bool = entered_work and _last_work_index != -1
		_last_work_index = work_index
		
		var current_index: int = item_index
		var item: Variant = work.get_sequence_item(item_index)
		item_index += 1
		
		return {
			"finished": false,
			"work": work,
			"item": item,
			"item_index": current_index,
			"entered_work": entered_work,
			"changed_work": changed_work
		}
	
	return {"finished": true, "work": null, "item": null, "entered_work": false, "changed_work": false}
