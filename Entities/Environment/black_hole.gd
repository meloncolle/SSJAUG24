@tool
extends Boostable

class_name BHEntity

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var pulsar: CollisionShape2D = $Pulsar
@export var pulse: float: set = set_pulse
@export var pulseSize: float: set = set_pulse_size

func set_pulse(v: float) -> void:
	pulse = clamp(v, 0, 1)

	if pulsar != null:
		pulsar.shape.radius = lerpf(0, gravityFieldSize, pulse)
		pulsar.debug_color.a = lerpf(1.25, 0, pulse)

func set_pulse_size(v: float) -> void:
	pulseSize = clamp(v, 0, 1)
	
	if pulsar != null:
		var s: float = lerpf(centerSize * .008, centerSize * .01, pulseSize)
		sprite.scale.x = s
		sprite.scale.y = s

func _on_center_entered(body: Node2D) -> void:
	if body is BallEntity:
		# Grant any points in inventory
		body.destroy(true)
	else:
		return

func set_appearance(gravity_strength: float) -> void:
	var c = Color.BLACK
	var ratio := inverse_lerp(0, Globals.MAX_GRAVITY, abs(gravity_strength))
	c.a = ratio
	gravityField.debug_color = c
	animationPlayer.speed_scale = lerp(0.3, 1.5, ratio)
