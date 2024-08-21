extends RigidBody2D

class_name BallEntity

var isTargeted := false

## Set this to make the game target this ball on game start.[br]
## If none are set, the first ball in the tree is targeted.[br]
## If multiple are set, the first ball in the tree with this set is targeted.[br]
@export var isFirstBall := false

var pointer: Node2D = null
var powerMeter: Node2D = null

signal ball_destroyed(index: int, destroyer: Node2D)

var index: int = -1 # Position in main ball array... Needs to be externally updated...

func _physics_process(delta: float) -> void:
	if isTargeted && pointer != null:
		pointer.look_at(get_global_mouse_position())

func destroy(points: int = 0):
	emit_signal("ball_destroyed", index, points)
	self.queue_free()

func set_index(set: int):
	index = set

func set_target(set: bool=true):
	set_pointer(set)
	isTargeted = set
		
func set_pointer(set: bool=true):
	if (is_instance_valid(pointer)):
		pointer.queue_free()
	if set:
		pointer = load("res://UI/Pointer.tscn").instantiate()
		self.add_child(pointer)
		pointer.look_at(get_global_mouse_position())
	else:
		pointer = null
		
func set_power_meter(set: bool=true):
	if (is_instance_valid(powerMeter)):
		powerMeter.queue_free()
	if set:
		powerMeter = load("res://UI/PowerMeter.tscn").instantiate()
		self.add_child(powerMeter)
	else:
		powerMeter = null
