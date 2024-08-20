extends Draggable

class_name BHEntity


func _on_points_you_body_entered(body: Node2D) -> void:
	if body is BallEntity:
		body.destroy(self)
	else:
		return
