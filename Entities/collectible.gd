extends Area2D

class_name Collectible

@export var pointValue: int = 1

signal collect_points(points: int)

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is BallEntity:
		if Globals.ENABLE_SIMPLE_COLLECTIBLES:
			destroy()
		else: 
			# Add to ball's trail i guess?
			return
	else:
		return
		
func destroy() -> void:
	emit_signal("collect_points", pointValue)
	self.queue_free()
