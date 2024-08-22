extends Node2D

var items: Array[Collectible] = []

@export var followSpeed: float = 5

var zoomEnabled = true


# todo: i want them to follow u soo bad but i cant get it to look good atm v_v
#func _process(delta):
	#for i in items.size():
		## todo: try this??
		## if lerped point intersects circle, move it along the ray intersecting circle center and lerped point until its outside da circle
		#var targetPos: Vector2 = global_position if i == 0 else items[i-1].position
		#items[i].position = items[i].position.lerp(targetPos, delta * followSpeed)
	
func add_item(item: Collectible):
	items.append(item)
