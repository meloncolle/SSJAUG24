extends Control

@onready var openingVid: VideoStreamPlayer = $OpeningVid
@onready var loopVid: VideoStreamPlayer = $LoopVid
@onready var fadeAnimationPlayer: AnimationPlayer = $FadeAnimationPlayer
@onready var btnAnimationPlayer: AnimationPlayer = $ButtonAnimationPlayer
@onready var titleMusic: AudioStreamPlayer = $TitleMusic
@onready var voiceOver: AudioStreamPlayer = $Voiceover

@export var resetTime: float = 30
var timer: float = 0
var timerActive: bool = true: set = set_timer_active

func _ready() -> void:
	reset()

func _process(delta: float) -> void:
	if !timerActive:
		return
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

	loopVid.stop()
	btnAnimationPlayer.stop()
	openingVid.visible = true
	titleMusic.volume_db = 0.0
	titleMusic.play()
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
	
	titleMusic.play(13.65)
	openingVid.visible = false
	voiceOver.play()
	openingVid.stop()
	loopVid.play()
	btnAnimationPlayer.play("button_enter")
	
	if fade:
		fadeAnimationPlayer.play_backwards("fade_to_black_noaudio")
		await fadeAnimationPlayer.animation_finished


func set_timer_active(val: bool) -> void:
	timerActive = val
	timer = 0
