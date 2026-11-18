class_name Choise extends Resource


@export var name: String ## Имя выбора

## Ключ — текст варианта ответа; значение — имя диалога, запускаемого при выборе.
@export var choises: Dictionary[String, String]
