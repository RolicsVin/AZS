## Класс персонажа.
## Содержит данные персонажа.
class_name Character extends Resource


@export_multiline var resume: String ## Резюме персонажа
@export_multiline var social_networks: Array[String] ## Посты в социальных сетях

@export var start_dialog: String ## Имя стартового диалога
@export var dialogs: Array[LinearDialog] ## Диалоги персонажа
@export var choises: Array[Choise] ## Выборы персонажа
