extends Sprite2D

@onready var bar = $Mask/Bar

var power: float = 0

var max_angle: float = PI * 2.12
var min_angle: float = PI / 2.6

func _ready():
	bar.connect("draw", draw_bar)
	
func _on_changed_power(newPower: float):
	power = newPower
	draw_bar()
	
func draw_bar():
	var lerpval = lerp(min_angle, max_angle, power)
	var thickness = lerp(50, 200, power) # line gets glitchy if it's too thick on low fuel
	bar.draw_arc(Vector2(-22, 10), 150, min_angle, lerpval, 32, Color.WHITE, thickness, true)
	bar.queue_redraw()
