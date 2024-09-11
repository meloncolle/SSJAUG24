extends Control

@onready var openingVid: VideoStreamPlayer = $OpeningVid
@onready var loopVid: VideoStreamPlayer = $LoopVid
@onready var fadeAnimationPlayer: AnimationPlayer = $FadeAnimationPlayer
@onready var btnAnimationPlayer: AnimationPlayer = $ButtonAnimationPlayer

@export var resetTime: float = 20
var timer: float = 0

func _ready() -> void:
	reset()

func _process(delta: float) -> void:
	timer += delta
	if timer >= resetTime:
		timer = 0
		reset(true)
		
func _input(event):
	if ((event is InputEventMouseButton and event.is_pressed()) ||
	(event is InputEventKey and event.is_pressed()) ||
	(event is InputEventMouseMotion)):
		# reset idle timer
		timer = 0
		
		if event is not InputEventMouseMotion && openingVid.visible:
			# skip anim
			go_to_end(true)

	
func reset(fade: bool = false):
	var levelsMenu = get_node_or_null("LevelsMenu")
	if levelsMenu != null:
		levelsMenu.queue_free()
	
	if fade:
		fadeAnimationPlayer.play("fade_to_black")
		await fadeAnimationPlayer.animation_finished

	btnAnimationPlayer.stop()
	openingVid.visible = true
	openingVid.play()
	
	if fade:
		fadeAnimationPlayer.play_backwards("fade_to_black")
		await fadeAnimationPlayer.animation_finished
	
	await openingVid.finished
	go_to_end()
	
func go_to_end(fade: bool = false):
	if fade:
		fadeAnimationPlayer.play("fade_to_black")
		await fadeAnimationPlayer.animation_finished
	
	openingVid.visible = false
	openingVid.stop()
	loopVid.play()
	btnAnimationPlayer.play("button_enter")
	
	if fade:
		fadeAnimationPlayer.play_backwards("fade_to_black")
		await fadeAnimationPlayer.animation_finished
