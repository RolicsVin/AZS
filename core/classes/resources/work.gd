## Рабочая смена: последовательность NodePath машин и ресурсов Event.
class_name Work extends Node3D

@export var anim_name: String
@export var sequence: Array[Variant] = []

func _ready() -> void:
	# Work подписывается на запросы событий, не заставляя Car знать о родителе.
	for child in get_children():
		if child is Car and not child.event_requested.is_connected(_on_car_event_requested):
			child.event_requested.connect(_on_car_event_requested.bind(child))


func _on_car_event_requested(event: Event, car: Car) -> void:
	add_event_after(car, event)


func get_sequence_item(index: int) -> Variant:
	if index < 0 or index >= sequence.size():
		return null
	var item: Variant = sequence[index]
	if item is NodePath:
		if item.is_empty():
			return null
		return get_node_or_null(item)
	return item

## Проверяет последовательность до запуска смены.
func validate_sequence() -> bool:
	var valid := true
	for index in range(sequence.size()):
		var item: Variant = get_sequence_item(index)
		if item is Car:
			if not item.validate_configuration():
				valid = false
		elif item is Event:
			if not item.validate_configuration():
				valid = false
		elif item == null:
			push_warning("Work '%s': элемент #%d не найден или пуст." % [name, index])
			valid = false
		else:
			push_warning("Work '%s': неподдерживаемый элемент #%d." % [name, index])
			valid = false
	return valid

## Вставляет событие после двух или трёх следующих машин.
func add_event_after(node: Node, event: Event) -> bool:
	if node == null or event == null or not event.validate_configuration():
		return false
	var start_index: int = sequence.find(get_path_to(node))
	if start_index == -1:
		push_warning("Work '%s': машина '%s' отсутствует в sequence." % [name, node.name])
		return false
	var cars_to_skip: int = randi_range(2, 3)
	var cars_found: int = 0
	var insert_index: int = start_index
	for index in range(start_index + 1, sequence.size()):
		var item: Variant = get_sequence_item(index)
		if item is Car:
			cars_found += 1
			insert_index = index
			if cars_found >= cars_to_skip:
				break
	sequence.insert(insert_index + 1, event)
	return true
