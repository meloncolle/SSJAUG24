extends RigidBody2D

class_name BallEntity

var isTargeted := false

## Set this to make the game target this ball on game start.[br]
## If none are set, the first ball in the tree is targeted.[br]
## If multiple are set, the first ball in the tree with this set is targeted.[br]
@export var isFirstBall := false

var pointer: Node2D = null
var powerMeter: Node2D = null

func _ready():
	pass
	
func _input(event):
	# Move aiming pointer to follow cursor
	if event is InputEventMouseMotion:
		if isTargeted && pointer != null:
			pointer.look_at(get_global_mouse_position())

func set_target(set: bool=true):
	set_pointer(set)
	isTargeted = set
		
func set_pointer(set: bool=true):
	if set:
		pointer = load("res://UI/Pointer.tscn").instantiate()
		self.add_child(pointer)
		pointer.look_at(get_global_mouse_position())
	else:
		if (is_instance_valid(pointer)):
			pointer.queue_free()
		pointer = null
		
func set_power_meter(set: bool=true):
	if set:
		powerMeter = load("res://UI/PowerMeter.tscn").instantiate()
		self.add_child(powerMeter)
	else:
		if (is_instance_valid(powerMeter)):
			powerMeter.queue_free()
		powerMeter = null
