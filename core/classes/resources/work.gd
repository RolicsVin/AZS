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


## Вставляет событие сразу после указанного узла в последовательности.
## Это позволяет показать реакцию на решение игрока до следующих машин и событий.
func add_event_after(node: Node, event: Event) -> void:
	if event == null:
		return

	var node_path: NodePath = get_path_to(node)
	var index: int = sequence.find(node_path)

	if index == -1:
		sequence.append(event)
	else:
		sequence.insert(index + 1, event)
