extends RigidBody2D

var state: Enums.BallState

@onready var arrow = $Arrow
@onready var powerMeter = $Meter

var power: float
var meter_timer:= 0.0
var meter_speed:= 7.5
var force_mult = 5.0

func _ready():
	set_power(0.0)
	set_state(Enums.BallState.READY)

func _input(event):
	match state:
		Enums.BallState.READY:
			if event is InputEventMouseMotion:
				arrow.look_at(get_global_mouse_position())
				pass
				
			elif (event is InputEventMouseButton 
					and event.button_index == MOUSE_BUTTON_LEFT 
					and event.pressed
				):
				set_state(Enums.BallState.IN_SWING)
				
		Enums.BallState.IN_SWING:
			if (event is InputEventMouseButton 
				and event.button_index == MOUSE_BUTTON_LEFT 
				and not event.pressed
				):
				set_state(Enums.BallState.WAITING)


func _process(delta):
	match state:
		Enums.BallState.IN_SWING:
			meter_timer += delta
			set_power((1 + cos(meter_timer * meter_speed)) * 0.5)

func do_swing():
	var swing = get_global_mouse_position() - position
	apply_central_impulse(swing * power * force_mult)
	print("SWANG with % power: " + str(power * 100))
	
func set_power(newVal: float):
	power = newVal
	powerMeter._on_changed_power(newVal)

func set_state(newState: Enums.BallState):
	state = newState
	print("NEW STATE: " + Enums.BallState.keys()[newState])
	match state:
		Enums.BallState.READY:
			arrow.visible = true
			#freeze = true
		Enums.BallState.IN_SWING:
			meter_timer = 0.0
			#freeze = true
		Enums.BallState.WAITING:
			arrow.visible = false
			#freeze = false
			do_swing()
			set_state(Enums.BallState.READY)
