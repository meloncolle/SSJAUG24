extends Node2D

class_name BaseLevel

var state: Enums.LevelState

var balls: Array[BallEntity] = []
var stars: Array[StarEntity] = []
var blackHoles: Array[BHEntity] = []

var activeBallIndex: int = -1

@onready var cam: Node2D = $Camera2D

func _ready():
	set_state(Enums.LevelState.INIT)
	print("Loaded level: " + self.name)
	
	# populate stars/balls/blackhole lists
	for b in $Planets.get_children():
		if b is BallEntity:
			balls.append(b)
	for s in $Stars.get_children():
		if s is StarEntity:
			stars.append(s)	
	for bh in $BlackHoles.get_children():
		if bh is BHEntity:
			blackHoles.append(bh)
			
	# Set active ball
	for i in range(balls.size()):
		if activeBallIndex == -1:
			activeBallIndex =  i
			if balls[i].isFirstBall:
				break
		elif balls[i].isFirstBall:
			activeBallIndex = i
			break
	
	assert(activeBallIndex != -1, "Ball not found in level")
	set_active_ball(activeBallIndex)
	
	set_state(Enums.LevelState.READY)
	# todo: connect to menu somehow...

func _input(event):
	
	match state:
		Enums.LevelState.READY:
			if event.is_action_pressed("ACTION"):
				set_active_ball(activeBallIndex + 1)

func set_active_ball(newIndex: int):
	if newIndex >= balls.size() || newIndex < 0:
		newIndex = newIndex % balls.size()
	
	if newIndex != activeBallIndex:
		balls[activeBallIndex].set_target(false)
	
	cam.set_target(balls[newIndex])
	
	activeBallIndex = newIndex
	balls[activeBallIndex].set_target()

func set_state(newState: Enums.LevelState):
	print("LEVEL STATE SET TO: " + Enums.LevelState.keys()[newState])
	var oldState := state
	
	match newState:
		Enums.LevelState.INIT:
			pass
		Enums.LevelState.READY:
			pass
		Enums.LevelState.IN_SWING:
			pass
		Enums.LevelState.GRAVITY:
			pass
		Enums.LevelState.DEAD:
			pass
	
	state = newState
