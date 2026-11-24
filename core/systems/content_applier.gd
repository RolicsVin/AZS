## Применяет проверенный контент к рабочим сменам. 
## Работает только с переданными объектами, поэтому проверяется без запуска сцены. 
class_name ContentApplier extends RefCounted


## Настраивает смены и вставляет события; возвращает сообщения о пропущенных вставках
func apply(bundle: ContentBundle, works: Array[Work]) -> Array[String]:
	var skipped: Array[String] = [] ## Сообщения о пропущенных вставках
	var works_by_name: Dictionary = {} ## Смены по имени узла
	for work in works:
		if work == null:
			continue
		work.event_gap_min = bundle.event_gap_min
		work.event_gap_max = bundle.event_gap_max
		works_by_name[String(work.name)] = work
	for insertion in bundle.insertions:
		var target: Work = works_by_name.get(insertion.work_name) as Work ## Смена-получатель
		if target == null:
			skipped.append(
				'Смена «%s» не найдена, событие «%s» не вставлено.'
				% [insertion.work_name, insertion.event.id]
			)
			continue
		if not target.insert_event_at(insertion.sequence_index, insertion.event):
			skipped.append(
				'Событие «%s» не вставлено в смену «%s».'
				% [insertion.event.id, insertion.work_name]
			)
	return skipped
