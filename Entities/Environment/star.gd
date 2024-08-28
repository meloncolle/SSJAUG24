@tool
extends Boostable

class_name StarEntity

@onready var dieSFX = $DieEmitter

func _on_center_entered(body: Node2D) -> void:
	if body is BallEntity:
		# Don't grant points in inventory
		body.destroy(false)
		dieSFX.play()
	else:
		return

func set_appearance(gravity_strength: float) -> void:
	var c = Color.CYAN if gravity_strength > 0 else Color.MAGENTA 
	c.a = inverse_lerp(0, Globals.MAX_GRAVITY, abs(gravity_strength))
	gravityField.debug_color = c
