## Класс персонажа. 
## Сожержит в себе данные персонажа. 
class_name Character extends Resource


@export var resume: String ## Резюме персонажа
@export var social_networks: Array[String] ## Посты в социльных сетях

@export var start_phrase: String
@export var dialogs: Dictionary[String, Array] ## Диалоги. Формат: ключ-str; значение-list[str]
