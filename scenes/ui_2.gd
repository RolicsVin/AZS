extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	$VBoxContainer/fuel.text = 'Топливо: ' + str(Data.fuel)
	$VBoxContainer/money.text = 'Деньги: ' + str(Data.money)
	$VBoxContainer/respect.text = 'Репутация: ' + str(Data.respect)
