extends Node2D

class_name BaseLevel

var state: Enums.LevelState:
	set = set_state

var balls: Array[BallEntity] = []

var activeBallIndex: int = -1

@onready var cam: Node2D = $Camera2D
@onready var deathScreen: Control = $UI/DeathScreen

@onready var power: Node = $Power
@onready var powerMeter: Node2D = $UI/PowerMeter

var score: int = 0
@onready var scoreLabel: RichTextLabel = $UI/ScoreLabel

@onready var fuel: Node = $Fuel
@onready var fuelLabel: RichTextLabel = $UI/FuelLabel

var strokes: int = 0: set = set_strokes
@onready var strokeLabel: RichTextLabel = $UI/StrokesLabel

###KYE STUFF
###KYE STUFF
###KYE STUFF
@onready var sfx = {
	"hitBall": $Audio/HitBall,
	"changeBall": $Audio/ChangeBall,
	"hitBallLowFuel": $Audio/HitBallLowFuel,
	"scoreGet": $Audio/ScoreGet,
	"fuelGet": $Audio/FuelGet,
	"collectibleGet": $Audio/CollectibleGet,
	"warpEnter": $Audio/WarpEnter,
	}

func _ready():
	state = Enums.LevelState.INIT
	set_score(0)
	set_strokes(0)
	
	# Check for at least one black hole
	var foundBH: bool = false
	for bh in $BlackHoles.get_children():
		if bh is BHEntity:
			foundBH = true
			break
	assert(foundBH, "Expected at least one black hole in level")
	
	# Check all wormholes have warp target assigned
	for wh in $WormHoles.get_children():
		if wh is WHEntity:
			assert(wh.warpTarget != null, "Wormhole \"" + wh.name + "\" needs to have warp target assigned")
			wh.connect("warped", func(): sfx.warpEnter.play())
	
	# Setup score signal for each collectible
	for c in $Collectibles.get_children():
		if c is Collectible:
			c.connect("granted_points", self.set_score)
			c.connect("collected", func(): sfx.collectibleGet.play())
		elif c is Fuel:
			c.connect("collect_fuel", func(val: float): fuel.fuel += val)
	
	# Populate ball list
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
	
	if Globals.sceneController != null:
		# Hook up button sounds (UI sound emitter is in main.tscn)
		for button in [
			deathScreen.get_node("Panel/VBoxContainer/RetryButton"),
			deathScreen.get_node("Panel/VBoxContainer/QuitButton"),
		]:
			button.pressed.connect(func(): Globals.sceneController.sfx.UIButtonPress.play())
			
		# Hook up submit score button on pause menu (yuck)
		Globals.sceneController.pauseMenu.submitButton.pressed.connect(end_level)
	
	power.connect("changed_power", $UI/PowerMeter/Mask/Bar._on_changed_power)
	fuel.connect("changed_fuel", _on_changed_fuel)
	fuel.connect("changed_fuel", power.check_limit)
	_on_changed_fuel(fuel.fuel, fuel.fuel) # to trigger UI to appear
	
	if Globals.ENABLE_INFINITE_FUEL:
		fuelLabel.visible = false
	
	state = Enums.LevelState.READY

func _input(event):
	if Globals.disableInput:
		return
	
	match state:
		Enums.LevelState.READY:
			# SPACE DOWN to change active ball
			if event.is_action_pressed("ACTION"):
				if Globals.ENABLE_SWITCHING_BALLS:
					set_active_ball(activeBallIndex + 1)
					sfx.changeBall.play()
				
			# LMB DOWN to start swing
			if (event is InputEventMouseButton 
				and event.button_index == MOUSE_BUTTON_LEFT 
				and event.pressed
			):
				state = Enums.LevelState.IN_SWING
			
		Enums.LevelState.IN_SWING:
			# LMB UP: do swing
			if (event is InputEventMouseButton 
				and event.button_index == MOUSE_BUTTON_LEFT 
				and not event.pressed
				):
				do_swing(power.power)
				state = Enums.LevelState.READY
				
		Enums.LevelState.DEAD:
			return

func do_swing(force: float):
	var swing = get_global_mouse_position() - balls[activeBallIndex].position
	# i think we have to multiply this by the camera zoom so the force is proportional?? weird
	balls[activeBallIndex].apply_central_impulse(swing * power.force * power.power * cam.zoom.y)
	if fuel.fuel >= Globals.MAX_FUEL_PER_SWING:
		sfx.hitBall.play()
	elif !sfx.hitBallLowFuel.is_playing():
		sfx.hitBallLowFuel.play()
		
	if !Globals.ENABLE_INFINITE_FUEL:
		fuel.fuel -= power.power * Globals.MAX_FUEL_PER_SWING 
		
	strokes += 1

func set_active_ball(newIndex: int):
	# todo: ideally we'd want to be able to go back-forth and order by spatial distance btwn balls
	if newIndex >= balls.size() || newIndex < 0:
		newIndex = newIndex % balls.size()
	
	if newIndex != activeBallIndex:
		balls[activeBallIndex].isTargeted = false
	
	cam.set_target(balls[newIndex])
	
	activeBallIndex = newIndex
	balls[activeBallIndex].isTargeted = true

func set_state(newState: Enums.LevelState):
	var _oldState := state
	
	match newState:
		Enums.LevelState.INIT:
			pass
			
		Enums.LevelState.READY:
			Globals.disableInput = false
			power.isOscillating = false
			powerMeter.visible = false
			
		Enums.LevelState.IN_SWING:
			power.reset()
			power.isOscillating = true
			powerMeter.visible = true
		
		Enums.LevelState.DEAD:
			Globals.disableInput = true
			deathScreen.visible = true
	state = newState

func set_score(newScore: int, baseScore: int = score):
	score = newScore + baseScore
	if score > baseScore:
		sfx.scoreGet.play()
	scoreLabel.text = "Score: " + str(score)
	
func set_strokes(val: int):
	strokes = val
	strokeLabel.text = "Strokes: " + str(strokes)

func _on_changed_fuel(newVal: float, oldVal: float):
	if newVal > oldVal:
		sfx.fuelGet.play()
	if newVal < Globals.MAX_FUEL_PER_SWING:
		fuelLabel.text = "Fuel: [color=#ff0000]" + "%.2f" % newVal + "[/color]"
	else:
		fuelLabel.text = "Fuel: " + "%.2f" % newVal

func update_ball_indices():
	var ballCount := 0
	for b in balls:
		b.set_index(ballCount)
		ballCount += 1

func _on_ball_destroyed(destroyedIndex: int, points: int = 0):
	if points != 0:
		set_score(points)
	
	balls.remove_at(destroyedIndex)
	if destroyedIndex <= activeBallIndex:
		activeBallIndex -= 1
	update_ball_indices()	
	
	if balls.size() == 0:
		end_level(true)
	else:
		set_active_ball(activeBallIndex)

func end_level(died: bool = false):
	state = Enums.LevelState.DEAD
	if died:
		print("no more balls :(")

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
