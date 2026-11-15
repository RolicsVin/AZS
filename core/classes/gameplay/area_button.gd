## Кнопка-область. 
class_name AreaButon extends Area3D

signal pressed ## Издаётся, когда был вызван метод "press"


func press():
	pressed.emit()
