## Класс персонажа. 
## Сожержит в себе данные персонажа. 
class_name Character extends Resource


@export_multiline var resume: String ## Резюме персонажа
@export_multiline var social_networks: Array[String] ## Посты в социльных сетях

@export var start_dialog: LinearDialog ## Стартовый диалог
@export var dialogs: Array[LinearDialog] ## Диалоги, которые содержатся в персонаже
@export var choises: Array[Choise] ## Выборы, которые содержатся в персонаже
