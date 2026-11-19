extends Camera3D

@export var speed: float = 5.0
@export var limit: float = 10.0
@export var mouse_sensitivity: float = 0.1

var normal_rotation: Vector3
var mouse_rotation: Vector2 = Vector2.ZERO


func _ready():
	normal_rotation = rotation_degrees
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_viewport().warp_mouse(get_viewport().size / 2)


func _input(event):
	if event is InputEventMouseMotion:
		mouse_rotation.x -= event.relative.y * mouse_sensitivity
		mouse_rotation.y -= event.relative.x * mouse_sensitivity
		
		mouse_rotation.x = clampf(mouse_rotation.x, -limit, limit)
		mouse_rotation.y = clampf(mouse_rotation.y, -limit, limit)


func _process(delta):
	var target_rotation: Vector3 = normal_rotation + Vector3(
		mouse_rotation.x,
		mouse_rotation.y,
		0.0
	)
	
	rotation_degrees = rotation_degrees.lerp(
		target_rotation,
		clampf(speed * delta, 0.0, 1.0)
	)
