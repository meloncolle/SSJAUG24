extends RigidBody2D

var dragging = false
@onready var collisionShape = $CollisionShape2D.shape

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not dragging and event.pressed:
			if (self.position.distance_to(event.position)) < collisionShape.radius:
				dragging = true
				freeze = true
			
		if dragging and not event.pressed:
			dragging = false
			freeze = false
			apply_central_impulse(Vector2.ZERO)

	if event is InputEventMouseMotion and dragging:
		global_transform.origin = get_global_mouse_position()
