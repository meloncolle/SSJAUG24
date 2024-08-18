extends RigidBody2D

var state: Enums.BallState

@onready var arrow = $Arrow
@onready var powerMeter = $Meter
@onready var cam = $Camera2D

var power: float # Power level for swing, based on meter timing
var meter_timer:= PI * 2

@export var cam_zoom_speed:= Vector2(0.1, 0.1) # Speed at which scrolling zooms in/out
@export var meter_speed:= 7.5 # Speed at which power meter oscillates
@export var force_mult = 4.0 # Multiplier for swing force

func _ready():
	set_state(Enums.BallState.READY)

func _input(event):
	# Scroll to zoom
	if event is InputEventMouseButton && event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			cam.zoom += cam_zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			cam.zoom -= cam_zoom_speed
	
	# Move aiming arrow to follow cursor
	if event is InputEventMouseMotion:
		if state == Enums.BallState.READY || state == Enums.BallState.IN_SWING:
			arrow.look_at(get_global_mouse_position())
	
	match state:
		Enums.BallState.READY:
			if (event is InputEventMouseButton 
					and event.button_index == MOUSE_BUTTON_LEFT 
					and event.pressed
				):
				# start swing
				set_state(Enums.BallState.IN_SWING)
				
		Enums.BallState.IN_SWING:
			if (event is InputEventMouseButton 
				and event.button_index == MOUSE_BUTTON_LEFT 
				and not event.pressed
				):
				# end swing
				set_state(Enums.BallState.WAITING)

func _process(delta):
	match state:
		Enums.BallState.IN_SWING:
			# Oscillate power level while charging swing
			meter_timer += delta
			set_power((1 + cos(meter_timer * meter_speed)) * 0.5)

func do_swing():
	var swing = get_global_mouse_position() - position
	# i think we have to multiply this by the camera zoom so the force is proportional?? weird
	apply_central_impulse(swing * power * force_mult * cam.zoom.y)
	print("SWANG with % power: " + str(power * 100))
	
func set_power(newVal: float):
	power = newVal
	powerMeter._on_changed_power(newVal)

func set_state(newState: Enums.BallState):
	state = newState
	#print("NEW STATE: " + Enums.BallState.keys()[newState])
	match state:
		Enums.BallState.READY:
			meter_timer = PI * 2
			set_power(0.0)
			arrow.visible = true
			powerMeter.visible = false
			#freeze = true
		Enums.BallState.IN_SWING:
			#freeze = true
			powerMeter.visible = true
		Enums.BallState.WAITING:
			arrow.visible = false
			powerMeter.visible = false
			#freeze = false
			do_swing()
			set_state(Enums.BallState.READY)


func _on_goal_body_entered(body: Node2D) -> void:
	print("GOAL")
	#Main._on_press_restart()
