extends Area2D

class_name Collectible

@export var pointValue: int = 1

signal collect_points(points: int)

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is BallEntity:
		if Globals.ENABLE_SIMPLE_COLLECTIBLES:
			destroy(true)
		else:
			body_entered.disconnect(_on_body_entered)
			visible = false
			body.inventory.add_item(self)
	else:
		return
		
func destroy(grantPoints: bool = false) -> void:
	if grantPoints:
		emit_signal("collect_points", pointValue)
	self.queue_free()
