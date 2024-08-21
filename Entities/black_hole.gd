@tool
extends Boostable

class_name BHEntity

func _on_center_entered(body: Node2D) -> void:
	if body is BallEntity:
		# give 1 point for this? for now?
		body.destroy(1)
	else:
		return

# ----------SETTERS/GETTERS----------
# this overrides "boostable" func to keep value positive, color black
func set_grav_field_strength(value: float) -> void:
	gravityStrength = max(0, value)
	self.gravity = gravityStrength
	
	# color stuff
	if gravityField != null:
		var c := Color.BLACK
		c.a = inverse_lerp(0, Globals.MAX_GRAVITY, abs(gravityStrength))
		gravityField.debug_color = c
