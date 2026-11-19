extends Control

@onready var chooser: Control = $Chooser

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	if not visible:
		return

	var mouse = get_global_mouse_position()
	var direction = mouse - chooser.global_position

	chooser.rotation = direction.angle()
