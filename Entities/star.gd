extends Draggable

class_name StarEntity


func _on_center_entered(body: Node2D) -> void:
	if body is BallEntity:
		body.destroy()
	else:
		return
