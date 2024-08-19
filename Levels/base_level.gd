extends Node2D

class_name BaseLevel

var state: Enums.LevelState

var balls: Array[BallEntity] = []
var stars: Array[StarEntity] = []
var blackHoles: Array[BHEntity] = []

var activeBallIndex: int = -1

@onready var cam: Node2D = $Camera2D

# Should this stuff be elsewhere?
var power: float # Power level for swing, based on meter timing
var meterTimer := PI * 2
@export var powerMeterSpeed := 7.5 ## Speed at which power meter oscillates
@export var swingForce := 4.0 ## Multiplier for swing force

signal changed_power(newPower: float)


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
	assert(blackHoles.size() > 0, "Expected at least one black hole in level")

			
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
			# SPACE DOWN to change active ball
			if event.is_action_pressed("ACTION"):
				set_active_ball(activeBallIndex + 1)
				
			# LMB DOWN to start swing
			if (event is InputEventMouseButton 
				and event.button_index == MOUSE_BUTTON_LEFT 
				and event.pressed
			):
				set_state(Enums.LevelState.IN_SWING)
			
			# RMB DOWN to manip gravity (IF UR NOT CLICKING A BUBBLE)
			if (event is InputEventMouseButton 
				and event.button_index == MOUSE_BUTTON_RIGHT 
				and event.pressed
			):
				var clickedDraggable := false
				for draggable in stars + blackHoles:
					# todo: DO THIS SMARTER IF WE KEEP IT...
					if draggable.is_point_inside(get_global_mouse_position()) && draggable.dragEnabled:
						clickedDraggable = true
						break
				
				if !clickedDraggable:
					print("TODO: manip gravity")
			
		Enums.LevelState.IN_SWING:
			# LMB UP: do swing
			if (event is InputEventMouseButton 
				and event.button_index == MOUSE_BUTTON_LEFT 
				and not event.pressed
				):
				do_swing(power)
				set_state(Enums.LevelState.READY)

func do_swing(force: float):
	var swing = get_global_mouse_position() - balls[activeBallIndex].position
	# i think we have to multiply this by the camera zoom so the force is proportional?? weird
	balls[activeBallIndex].apply_central_impulse(swing * force * swingForce * cam.zoom.y)

func _physics_process(delta):
	match state:
		Enums.LevelState.IN_SWING:
			# Oscillate power level while charging swing
			meterTimer += delta
			set_power((1 + cos(meterTimer * powerMeterSpeed)) * 0.5)

func set_power(newVal: float):
	power = newVal
	emit_signal("changed_power", power)

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
			# remove powermeter
			balls[activeBallIndex].set_power_meter(false)
			
		Enums.LevelState.IN_SWING:
			# setup powermeter
			meterTimer = PI * 2
			balls[activeBallIndex].set_power_meter()
			if balls[activeBallIndex].powerMeter != null:
				self.connect("changed_power", balls[activeBallIndex].powerMeter._on_changed_power)
				
		Enums.LevelState.GRAVITY:
			pass
		Enums.LevelState.DEAD:
			pass
	
	state = newState
