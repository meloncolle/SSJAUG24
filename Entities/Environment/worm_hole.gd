@tool
extends Boostable

class_name WHEntity

## The wormhole that this one warps you to
@export var warpTarget: WHEntity = null

signal warped()

func _on_center_entered(body: Node2D) -> void:
	if body is BallEntity:
		var success: bool = body.warp(self, warpTarget)
		if success:
			warped.emit()
	else:
		return
		
func _on_center_exited(body: Node2D) -> void:
	if body is BallEntity:
		body.lastWarpSource = null
	else:
		return

func set_appearance(gravity_strength: float) -> void:
	var c = Color.CYAN
	c.a = inverse_lerp(0, Globals.MAX_GRAVITY, abs(gravity_strength))
	gravityField.debug_color = c
