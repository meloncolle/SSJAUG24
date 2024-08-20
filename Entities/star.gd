@tool
extends Draggable

class_name StarEntity

@onready var gravityField: CollisionShape2D = $GravityField

## Radius of star's gravity field
@export_range(0.01, 1024, 0.1, "suffix: px") var gravity_field_size = 150:
	set(value):
		gravity_field_size = value
		if gravityField != null:
			# idk why the null check is needed? it tries to do it on an [orphan] node at start otherwise??
			gravityField.shape.radius = gravity_field_size
			
## Strength of star's gravity field
@export_range(Globals.MIN_GRAVITY, Globals.MAX_GRAVITY, 0.1, "suffix: px/s²") var gravity_strength = 980:
	set(value):
		gravity_strength = value
		self.gravity = gravity_strength
		
		# color stuff
		if gravityField != null:
			var c := Color.CYAN
			if gravity_strength < 0:
				c = Color.MAGENTA
			c.a = inverse_lerp(0, Globals.MAX_GRAVITY, abs(gravity_strength))
			gravityField.debug_color = c
			
func _ready():
	gravityField.shape.radius = gravity_field_size
	gravity_strength = self.gravity

func _on_center_entered(body: Node2D) -> void:
	if body is BallEntity:
		body.destroy(self)
	else:
		return
