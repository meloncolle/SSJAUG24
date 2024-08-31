extends Area2D

class_name Draggable

@export var dragEnabled := true

var dragging := false
var dragPoint: Vector2

@onready var collisionShape: Shape2D = $GravityField.shape

func _input(event):
	if Globals.disableInput || !dragEnabled:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if not dragging and event.pressed:
			if is_point_inside(get_global_mouse_position()):
				dragging = true
				dragPoint = self.global_position - get_global_mouse_position()
			
		if dragging and not event.pressed:
			dragging = false

	if event is InputEventMouseMotion and dragging:
		self.global_position = get_global_mouse_position() + dragPoint
		
func is_point_inside(point: Vector2) -> bool:
	return self.global_position.distance_to(point) < collisionShape.radius
