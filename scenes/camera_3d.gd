
extends Camera3D

@export var speed = 5.0
@export var limit = 30.0
@export var speed1 = 5.0
@export var limit1 = 0.5

var modepos = false
var normal_rotation: Vector3
var normal_position: Vector3

func _ready():
	normal_rotation = rotation_degrees
	normal_position = position

func _process(delta):
	if Input.is_action_just_pressed("interact"):
		modepos = not modepos

	var mouse = get_viewport().get_mouse_position() / Vector2(get_viewport().size)

	if modepos:
		var target_position = Vector3(
			normal_position.x + (mouse.x - 0.5) * limit1,
			normal_position.y,
			normal_position.z + (mouse.y - 0.5) * limit1
		)

		var target_rotation = normal_rotation + Vector3(-90.0, 0.0, 0.0)

		position = position.lerp(target_position, clampf(speed * delta, 0.0, 1.0))
		rotation_degrees = rotation_degrees.lerp(target_rotation, clampf(speed1 * delta, 0.0, 1.0))

	else:
		var target_rotation = normal_rotation + Vector3(
			-(mouse.y - 0.5) * limit,
			-(mouse.x - 0.5) * limit,
			0.0
		)

		position = position.lerp(normal_position, clampf(speed1 * delta, 0.0, 1.0))
		rotation_degrees = rotation_degrees.lerp(target_rotation, clampf(speed * delta, 0.0, 1.0))
