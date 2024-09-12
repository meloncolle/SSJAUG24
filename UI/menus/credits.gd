extends Control

var fullHeight: float = 340

@export var opened: float: set = set_opened
@onready var menu: Control = $MarginContainer
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

var closing: = false
	
func set_opened(v: float) -> void:
	opened = clamp(v, 0, 1)

	menu.size.y = lerpf(0, fullHeight, opened)
	menu.position.y = (get_viewport().get_visible_rect().size.y - menu.size.y) * 0.5

func _input(event):
	if closing:
		return
	if ((event is InputEventMouseButton and event.is_pressed()) ||
	(event is InputEventKey and event.is_pressed())):
		closing = true
		animationPlayer.play_backwards("open")
		await animationPlayer.animation_finished
		queue_free()
