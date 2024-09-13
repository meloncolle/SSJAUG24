@tool
extends Boostable

class_name StarEntity

@onready var dieSFX = $DieEmitter
@export var hurtsYou = true

func _init():
	rotationSpeed = 0.25

func _on_center_entered(body: Node2D) -> void:
	if !hurtsYou:
		return
	if body is BallEntity:
		# Don't grant points in inventory
		body.destroy(false)
		dieSFX.play()
	else:
		return

func set_appearance(gravity_strength: float) -> void:
	var c = Color.YELLOW if gravity_strength > 0 else Color.MAGENTA 
	c.a = inverse_lerp(0, Globals.MAX_GRAVITY, abs(gravity_strength))
	gravityField.debug_color = c
