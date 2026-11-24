## Один шаг последовательности смен, который выдаёт SequenceController. 
class_name SequenceEntry extends RefCounted

var finished: bool = false ## Все смены пройдены, элемента нет
var work: Work ## Смена, которой принадлежит элемент
var item: Variant = null ## Элемент: Car, Event или null, если он не найден
var item_index: int = -1 ## Индекс элемента в последовательности смены
var entered_work: bool = false ## Это первый элемент новой смены
var changed_work: bool = false ## Переход в новую смену не из первой
