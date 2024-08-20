extends Node2D

class_name BaseLevel

var state: Enums.LevelState

var balls: Array[BallEntity] = []
var stars: Array[StarEntity] = []
var blackHoles: Array[BHEntity] = []

var activeBallIndex: int = -1

@onready var cam: Node2D = $Camera2D
@onready var deathScreen: Control = $CanvasLayer/DeathScreen

# Should this stuff be elsewhere?
var power: float # Power level for swing, based on meter timing
var meterTimer := PI * 2
@export_group("Swing Settings")
@export var swingForce := 4.0 ## Multiplier for swing force
@export var powerMeterSpeed := 7.5 ## Speed at which power meter oscillates

var score: int
@onready var scoreLabel: RichTextLabel = $CanvasLayer/Points

var gravBoostActive: bool = false
@export_group("Gravity Boost Settings")
@export var gravityBoostLimit: float = 4096 ## Upper limit for gravity when boosting
@export var gravityBoostSpeed := 7.5 ## Speed at which gravity is increased

signal changed_power(newPower: float)

func _ready():
	set_state(Enums.LevelState.INIT)
	set_score(0)
		
	# populate stars/balls/blackhole lists
	for s in $Stars.get_children():
		if s is StarEntity:
			stars.append(s)	
	for bh in $BlackHoles.get_children():
		if bh is BHEntity:
			blackHoles.append(bh)
	assert(blackHoles.size() > 0, "Expected at least one black hole in level")
	
	for b in $Planets.get_children():
		if b is BallEntity:
			balls.append(b)
	
	# Set up listener for when a ball is destroyed
	for b in balls:
		b.connect("ball_destroyed", self._on_ball_destroyed)
		
	update_ball_indices()
	
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
	
	# Hook up death screen buttons
	deathScreen.get_node("Panel/VBoxContainer/RetryButton").pressed.connect(_on_press_retry)
	deathScreen.get_node("Panel/VBoxContainer/QuitButton").pressed.connect(_on_press_quit)
	
	set_state(Enums.LevelState.READY)

func _input(event):
	# RMB UP to stop gravity manip at any point
	if (event is InputEventMouseButton 
		and event.button_index == MOUSE_BUTTON_RIGHT 
		and !event.pressed
	):
		if gravBoostActive:
			gravBoostActive = false
	
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
					gravBoostActive = true
			
		Enums.LevelState.IN_SWING:
			# LMB UP: do swing
			if (event is InputEventMouseButton 
				and event.button_index == MOUSE_BUTTON_LEFT 
				and not event.pressed
				):
				do_swing(power)
				set_state(Enums.LevelState.READY)
				
		Enums.LevelState.DEAD:
			return

func _physics_process(delta):
	if gravBoostActive:
		for s in stars:
			if s.gravityStrength < gravityBoostLimit:
				s.gravityStrength += gravityBoostSpeed
	else:
		for s in stars:
			if s.gravityStrength > s.baseGravity:
				s.gravityStrength -= gravityBoostSpeed
	
	match state:
		Enums.LevelState.IN_SWING:
			# Oscillate power level while charging swing
			meterTimer += delta
			set_power((1 + cos(meterTimer * powerMeterSpeed)) * 0.5)

func do_swing(force: float):
	var swing = get_global_mouse_position() - balls[activeBallIndex].position
	# i think we have to multiply this by the camera zoom so the force is proportional?? weird
	balls[activeBallIndex].apply_central_impulse(swing * force * swingForce * cam.zoom.y)

func set_power(newVal: float):
	power = newVal
	emit_signal("changed_power", power)

func set_active_ball(newIndex: int):
	# todo: ideally we'd want to be able to go back-forth and order by spatial distance btwn balls
	if newIndex >= balls.size() || newIndex < 0:
		newIndex = newIndex % balls.size()
	
	if newIndex != activeBallIndex:
		balls[activeBallIndex].set_target(false)
	
	cam.set_target(balls[newIndex])
	
	activeBallIndex = newIndex
	balls[activeBallIndex].set_target()

func set_state(newState: Enums.LevelState):
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
			deathScreen.visible = true
	
	state = newState

func set_score(newScore: int):
	score = newScore
	scoreLabel.text = str(score)
	

func update_ball_indices():
	var ballCount := 0
	for b in balls:
		b.set_index(ballCount)
		ballCount += 1

func _on_ball_destroyed(destroyedIndex: int, destroyer: Node2D):
	if destroyer is BHEntity:
		print("SCORE!")
		set_score(score + 1)
	else:
		print("BALL DESTROYED...")
	
	balls.remove_at(destroyedIndex)
	if destroyedIndex <= activeBallIndex:
		activeBallIndex -= 1
	update_ball_indices()	
	
	if balls.size() == 0:
		set_state(Enums.LevelState.DEAD)
		return
		
	set_active_ball(activeBallIndex)
	
func _on_press_retry():
	if Globals.sceneController != null:
		# If running full game context
		Globals.sceneController._on_press_restart()
	else:
		# If running just the level scene
		get_tree().reload_current_scene()
	
func _on_press_quit():
	if Globals.sceneController != null:
		# If running full game context
		Globals.sceneController._on_press_quit()
	else:
		# If running just the level scene
		get_tree().quit()
