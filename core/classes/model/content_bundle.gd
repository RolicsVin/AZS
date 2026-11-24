## Результат загрузки внешнего контента: настройки, события, вставки и сообщения об ошибках. 
## Только хранит данные и не имеет доступа к сцене и глобальному состоянию. 
class_name ContentBundle extends RefCounted


## Вставка события в смену по данным из файла контента. 
class Insertion extends RefCounted:
	var work_name: String = '' ## Имя узла смены
	var sequence_index: int = -1 ## Индекс в последовательности смены, -1 — в конец
	var event: Event ## Вставляемое событие


var is_loaded: bool = false ## Файл прочитан и имеет поддерживаемую версию формата
var start_money: int = 0 ## Начальное количество денег
var start_respect: int = 0 ## Начальная репутация
var transition_duration: float = -1.0 ## Длительность затемнения; отрицательное — не задано
var event_gap_min: int = 2 ## Минимум машин до вставки события после решения
var event_gap_max: int = 3 ## Максимум машин до вставки события после решения
var events: Dictionary = {} ## Проверенные события: id (String) -> Event
var insertions: Array[Insertion] = [] ## Проверенные вставки событий в смены
var errors: Array[String] = [] ## Сообщения об отброшенных или исправленных данных
