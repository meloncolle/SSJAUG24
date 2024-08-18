extends Camera2D

@export var target: Node2D = null
@export var followSpeed: float = 0.5
@export var zoomSpeed: float = 0.1

var t = 0.0

func set_target(_target):
	t = 0.0
	target = _target

func _process(delta):
	if target == null:
		return
	t += delta * followSpeed

	global_position = global_position.lerp(target.global_position, t)

func _input(event):
	# Scroll to zoom
	if event is InputEventMouseButton && event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom.x += zoomSpeed
			zoom.y += zoomSpeed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom.x -= zoomSpeed
			zoom.y -= zoomSpeed
