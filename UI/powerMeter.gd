extends Polygon2D

@onready var bar = $Bar

func _on_changed_power(newPower: float):
	bar.scale.y = newPower
