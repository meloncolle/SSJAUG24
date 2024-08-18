extends Area2D

class_name Draggable

@export var draggable = true

var dragging = false
var dragPoint: Vector2

@onready var collisionShape = $CollisionShape2D.shape

func _input(event):
	if !draggable:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if not dragging and event.pressed:
			if (self.global_position.distance_to(get_global_mouse_position())) < collisionShape.radius:
				dragging = true
				dragPoint = self.global_position - get_global_mouse_position()
			
		if dragging and not event.pressed:
			dragging = false

	if event is InputEventMouseMotion and dragging:
		self.global_position = get_global_mouse_position() + dragPoint
