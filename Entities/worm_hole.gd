@tool
extends Boostable

class_name WHEntity

## The wormhole that this one warps you to
@export var warpTarget: WHEntity = null

func _on_center_entered(body: Node2D) -> void:
	if body is BallEntity:
		var warped: bool = body.warp(self, warpTarget)
	else:
		return
		
func _on_center_exited(body: Node2D) -> void:
	if body is BallEntity:
		body.lastWarpSource = null
	else:
		return

func set_appearance(gravity_strength: float) -> void:
	var c = Color.GREEN 
	c.a = inverse_lerp(0, Globals.MAX_GRAVITY, abs(gravity_strength))
	gravityField.debug_color = c
