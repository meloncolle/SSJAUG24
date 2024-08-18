extends RigidBody2D

class_name BallEntity

var isTargeted: = false

## Set this to make the game target this ball on game start.[br]
## If none are set, the first ball in the tree is targeted.[br]
## If multiple are set, the first ball in the tree with this set is targeted.[br]
@export var isFirstBall = false

@onready var pointer:= $Pointer


func _ready():
	pass

func set_target(set: bool=true):
	pointer.visible = set
	isTargeted = set
