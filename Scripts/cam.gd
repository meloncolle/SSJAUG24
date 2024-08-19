extends Camera2D

@export var target: Node2D = null
@export var followSpeed: float = 5
@export var zoomSpeed: float = 0.1

var zoomEnabled = true

func set_target(_target):
	target = _target

func _process(delta):
	if target == null:
		return
	global_position = global_position.lerp(target.global_position, delta * followSpeed)

func _input(event):
	# Scroll to zoom
	if event is InputEventMouseButton && event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP && zoomEnabled:
			zoom.x += zoomSpeed
			zoom.y += zoomSpeed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN && zoomEnabled:
			zoom.x -= zoomSpeed
			zoom.y -= zoomSpeed
