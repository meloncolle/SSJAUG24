@tool
extends Draggable

class_name StarEntity

var baseGravity: float = 0

@onready var gravityField: CollisionShape2D = $GravityField

## Radius of star's gravity field
@export_range(0.01, 1024, 0.1, "suffix: px") var gravityFieldSize = 150:
	set(value):
		gravityFieldSize = value
		if gravityField != null:
			# idk why the null check is needed? it tries to do it on an [orphan] node at start otherwise??
			gravityField.shape.radius = gravityFieldSize
			
## Strength of star's gravity field
@export_range(Globals.MIN_GRAVITY, Globals.MAX_GRAVITY, 0.1, "suffix: px/s²") var gravityStrength = 980:
	set(value):
		gravityStrength = value
		self.gravity = gravityStrength
		
		# color stuff
		if gravityField != null:
			var c := Color.CYAN
			if gravityStrength < 0:
				c = Color.MAGENTA
			c.a = inverse_lerp(0, Globals.MAX_GRAVITY, abs(gravityStrength))
			gravityField.debug_color = c
			
func _ready():
	gravityField.shape.radius = gravityFieldSize
	gravityStrength = self.gravity
	
	baseGravity = gravityStrength

func _on_center_entered(body: Node2D) -> void:
	if body is BallEntity:
		body.destroy(self)
	else:
		return
