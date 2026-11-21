## Одна рабочая смена.
## Машины являются дочерними узлами Work, события — ресурсами Event.
class_name Work extends Node3D

@export var sequence: Array[Variant] = [] ## Последовательность NodePath машин и ресурсов Event


func get_sequence_item(index: int) -> Variant:
	if index < 0 or index >= sequence.size():
		return null

	var item: Variant = sequence[index]
	if item is NodePath:
		return get_node_or_null(item)

	return item
