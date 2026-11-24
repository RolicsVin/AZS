## Набор узлов интерфейса, которые UIController получает от Game. 
## Только Game знает пути к узлам сцены, остальные модули работают с этими ссылками. 
class_name UIBindings extends RefCounted

var main_ui: Control ## Корневой контейнер интерфейса
var resume: Node ## Узел с резюме посетителя (метод set_text)
var web: Control ## Панель социальных сетей (метод set_text)
var event_panel: Control ## Панель события
var event_card: Control ## Карточка текста события
var event_label: Label ## Текст события
var event_continue_button: Control ## Кнопка продолжения после события
var end_label: Control ## Надпись финального экрана
var dialog: Control ## Узел диалога
var back_button: Button ## Кнопка возврата из социальных сетей
var decision_buttons: Array[AreaButon] = [] ## Кнопки принятия и отказа
