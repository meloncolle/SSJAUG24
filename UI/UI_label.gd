extends RichTextLabel

@export var format: String = ""
@export var changeSpeed: float = 10

var warnThreshold: float = -1
var value = 0
var dispVal = 0

func _ready():
	update_text()
	
func _process(delta):
	if dispVal != value: # todo: check for range?
		dispVal = lerp(float(dispVal), float(value), delta * changeSpeed)
		update_text()

func update_text() -> void:
	if dispVal < warnThreshold:
		text = "[color=#ff0000]" + format % dispVal + "[/color]"
	else:
		text = format % dispVal
