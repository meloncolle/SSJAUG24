@tool
extends Area2D

class_name Boostable

## If this object can be gravity boosted
@export var boostEnabled := true
@export var allowNegativeGravity := true

## Radius of gravity field
@export_range(0.01, 1024, 0.1, "suffix: px") var gravityFieldSize = 150:
	set = set_grav_field_size
			
## Strength of gravity field
@export_range(Globals.MIN_GRAVITY, Globals.MAX_GRAVITY, 0.1, "suffix: px/s²") var gravityStrength = 980:
	set = set_grav_field_strength
	
## Radius of Center
@export_range(0.01, 1024, 0.1, "suffix: px") var centerSize = 10:
	set = set_center_size

@onready var gravityField: CollisionShape2D = $GravityField
@onready var center: CollisionShape2D = $Center/CollisionShape2D

var baseGravity := 0.0
var isBoosting := false

#@onready var gravityBoostSFX = $GravityBoostEmitter

func _ready():
	$Center.body_entered.connect(_on_center_entered)
	$Center.body_exited.connect(_on_center_exited)
	gravityField.shape.radius = gravityFieldSize
	center.shape.radius = centerSize
	gravityStrength = self.gravity
	
	baseGravity = gravityStrength

func _physics_process(_delta):
	if not Engine.is_editor_hint():
		if isBoosting:
			if gravityStrength < Globals.GRAVITY_BOOST_LIMIT:
				gravityStrength += Globals.GRAVITY_BOOST_SPEED
		else:
			if gravityStrength > baseGravity:
				gravityStrength -= Globals.GRAVITY_BOOST_SPEED

func _input(event):
	if not Engine.is_editor_hint():
		if Globals.disableInput || !boostEnabled:
			return
		
		if (event is InputEventMouseButton 
			and event.button_index == MOUSE_BUTTON_RIGHT 
			and event.pressed
			and is_point_inside(get_global_mouse_position())
		):
			isBoosting = true
		
		elif (event is InputEventMouseButton 
			and event.button_index == MOUSE_BUTTON_RIGHT 
			and !event.pressed
		):
			isBoosting = false
			
		if (event is InputEventMouseMotion
			and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
			isBoosting = is_point_inside(get_global_mouse_position())

func is_point_inside(point: Vector2) -> bool:
	return self.global_position.distance_to(point) < gravityField.shape.radius

func _on_center_entered(_body: Node2D) -> void:
	# Override this in child class n_n
	return
	
func _on_center_exited(_body: Node2D) -> void:
	# Override this in child class n_n
	return
	
func set_appearance(_gravity_strength: float) -> void:
		# Override this in child class n_n
	return

# ----------SETTERS/GETTERS----------

func set_grav_field_size(value: float) -> void:
	gravityFieldSize = value
	if gravityField != null:
		# idk why the null check is needed? it tries to do it on an [orphan] node at start otherwise??
		gravityField.shape.radius = gravityFieldSize
		
func set_grav_field_strength(value: float) -> void:
	if !allowNegativeGravity:
		gravityStrength = max(0, value)
	else:
		gravityStrength = value
	self.gravity = gravityStrength
	#if baseGravity != gravityStrength and gravityBoostSFX.is_playing == false:
	#	gravityBoostSFX.play()
	#else:
	#	gravityBoostSFX.stop()
	
	# sfx pitch = basegravity -= gravity strength
	if gravityField != null:
		set_appearance(gravityStrength)
		
func set_center_size(value: float) -> void:
	centerSize = value
	if center != null:
		# idk why the null check is needed? it tries to do it on an [orphan] node at start otherwise??
		center.shape.radius = centerSize
