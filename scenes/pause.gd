extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		visible = not visible 
		get_tree().paused = not get_tree().paused


func _on_resume_pressed() -> void:
	visible = false
	get_tree().paused = false



func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	get_tree().paused = false
