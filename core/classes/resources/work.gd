## Одна рабочая смена.
## Машины являются дочерними узлами Work, события — ресурсами Event.
class_name Work extends Node3D

@export var anim_name: String ## Какую анимацию проигрывать во время этйо рабочей смены
@export var sequence: Array[Variant] = [] ## Последовательность NodePath машин и ресурсов Event


func get_sequence_item(index: int) -> Variant:
	if index < 0 or index >= sequence.size():
		return null

	var item: Variant = sequence[index]
	if item is NodePath:
		return get_node_or_null(item)

	return item


## Вставляет событие после случайных двух или трёх следующих машин.
## Промежуточные Event не учитываются при подсчёте машин.
func add_event_after(node: Node, event: Event) -> void:
	if event == null:
		return

	var node_path: NodePath = get_path_to(node)
	var start_index: int = sequence.find(node_path)

	if start_index == -1:
		sequence.append(event)
		return

	var cars_to_skip: int = randi_range(2, 3)
	var cars_found: int = 0
	var insert_index: int = start_index

	for i in range(start_index + 1, sequence.size()):
		var item: Variant = get_sequence_item(i)
		if item is Car:
			cars_found += 1
			insert_index = i
			if cars_found >= cars_to_skip:
				break

	# Если в смене осталось меньше двух-трёх машин, вставляем событие
	# после последней доступной машины, не теряя его.
	if cars_found == 0:
		insert_index = sequence.size() - 1

	sequence.insert(insert_index + 1, event)
