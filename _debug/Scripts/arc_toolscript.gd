## Helper toolscript for spawning objects in an arc for level building

@tool extends Node

@export_group("Actions (toggle to execute)")
## Toggle this to spawn in the arc
@export var make_arc: bool: set = makeArc
## Toggle this to delete the last arc (only 1 step back, cannot be undone)
@export var undo_last: bool: set = undo

@export_group("Arc Settings")
## Which resource to spawn in
@export var resource: PackedScene = load("res://Entities/Collectible/Collectible.tscn")
## How many of the resource to include in arc
@export_range(0, 1000) var density: int = 36
## Starting angle for arc (0-360)
@export_range(0, 360, 1, "degrees") var start_angle : float = 0
## Ending angle for arc (0-360)
@export_range(0, 360, 1, "degrees") var end_angle : float = 360
## Offset added to angle (0-360)
@export_range(0, 360, 1, "degrees") var angle_offset : float = 0
## X radius of arc
@export_range(0, 9999, 1,  "suffix: px") var x_radius : float = 250
## Y radius of arc
@export_range(0, 9999, 1,  "suffix: px") var y_radius : float = 250

var last_arc: Array[Node2D] = []

func makeArc(_val: bool) -> void:
	var angle: float
	var pos: Vector2
	
	var gap: float = (end_angle - start_angle) / density
	var loop =  density
	
	if end_angle - start_angle < 360:
		gap = (end_angle - start_angle) / (density - 1)

	for i in loop:
		angle = deg_to_rad((gap * i) + start_angle + angle_offset)
		pos = Vector2(cos(angle) * x_radius, sin(angle) * y_radius)
		
		var item: Node2D = load(resource.resource_path).instantiate()
		add_child(item, true)
		item.owner = self.get_parent()
		item.position = pos
		
		last_arc.append(item)
			
func undo(_val: bool) -> void:
	var i: int = 0
	for item in last_arc:
		if (is_instance_valid(item)):
			item.queue_free()
			i += 1
	
	last_arc = []
	print("Removed " + str(i) + " items")
		
