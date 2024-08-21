@tool
extends Boostable

class_name BHEntity

func _on_center_entered(body: Node2D) -> void:
	if body is BallEntity:
		# give 1 point for this? for now?
		body.destroy(1)
	else:
		return

func set_appearance(gravity_strength: float) -> void:
	var c = Color.BLACK
	c.a = inverse_lerp(0, Globals.MAX_GRAVITY, abs(gravity_strength))
	gravityField.debug_color = c
