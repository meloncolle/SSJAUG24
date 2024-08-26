@tool
extends Boostable

class_name BHEntity

@onready var scoreSFX = $ScoreEmitter

func _on_center_entered(body: Node2D) -> void:
	if body is BallEntity:
		# Grant any points in inventory
		body.destroy(true)
		scoreSFX.play()
	else:
		return

func set_appearance(gravity_strength: float) -> void:
	var c = Color.DARK_CYAN
	c.a = inverse_lerp(0, Globals.MAX_GRAVITY, abs(gravity_strength))
	gravityField.debug_color = c
