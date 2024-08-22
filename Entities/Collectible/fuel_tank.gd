extends Area2D

class_name Fuel

@export var fuelValue: float = 25.0

signal collect_fuel(fuel: float)

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is BallEntity:
			destroy()
	else:
		return
		
func destroy() -> void:
	emit_signal("collect_fuel", fuelValue)
	self.queue_free()
