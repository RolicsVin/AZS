## Размещает свои дочерние узлы по кругу. 
@tool
class_name CircularContainer extends Container

## Радиус окружности.
@export_range(0.0, 2000.0, 1.0, "or_greater")
var radius: float = 100.0:
	set(value):
		radius = value
		queue_sort()

## Начальный угол в градусах.
@export_range(-360.0, 360.0, 1.0)
var start_angle: float = -90.0:
	set(value):
		start_angle = value
		queue_sort()

## Дополнительное вращение всей окружности.
@export_range(-360.0, 360.0, 1.0)
var rotation_offset: float = 0.0:
	set(value):
		rotation_offset = value
		queue_sort()

## Распределять элементы по часовой стрелке.
@export
var clockwise: bool = true:
	set(value):
		clockwise = value
		queue_sort()


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		_arrange_children()


func _arrange_children() -> void:
	var children: Array[Control] = []

	for child in get_children():
		if child is Control and not child.top_level:
			children.append(child)

	var count := children.size()
	if count == 0:
		return

	var center := size / 2.0
	var direction := 1.0 if clockwise else -1.0

	for i in range(count):
		var child := children[i]

		var angle := deg_to_rad(
			start_angle + rotation_offset +
			direction * (360.0 / count) * i
		)

		var position := center + Vector2(
			cos(angle),
			sin(angle)
		) * radius

		# Центрируем сам элемент относительно точки окружности.
		position -= child.size / 2.0

		fit_child_in_rect(
			child,
			Rect2(position, child.size)
		)


func _notification_resized() -> void:
	queue_sort()
