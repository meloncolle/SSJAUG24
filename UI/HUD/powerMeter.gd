extends Polygon2D

@onready var bar = $Bar

func _on_changed_power(power: float):
	bar.scale.y = power
