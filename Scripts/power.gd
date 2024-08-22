extends Node

@export var force := 4.0 ## Multiplier for swing force
@export var meterSpeed := 7.5 ## Speed at which power meter oscillates

signal changed_power(newPower: float)

var power: float:
	set = set_power

var isOscillating: bool = false
var meterTimer: float

func _ready():
	reset()

func _physics_process(delta):
	if isOscillating:
		meterTimer += delta
		set_power((1 + cos(meterTimer * meterSpeed)) * 0.5)

func reset():
	meterTimer = PI * 2
	set_power(0)

func set_power(value: float) -> void:
	power = value
	emit_signal("changed_power", power)
