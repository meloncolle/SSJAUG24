extends Node

@export var maxFuel: float = 100.0
@export var startingFuel: float = maxFuel

signal changed_fuel(newFuel: float)

func _ready():
	fuel = startingFuel
	
var fuel: float:
	set = set_fuel
	
func set_fuel(value: float) -> void:
	fuel = clamp(value, 0, maxFuel)
	emit_signal("changed_fuel", fuel)
