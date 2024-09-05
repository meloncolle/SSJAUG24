extends ColorRect

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

@onready var resumeButton: Button = $ResumeButton
@onready var submitButton: Button = $SubmitButton
@onready var restartButton: Button = $RestartButton
@onready var quitButton: Button = $QuitButton

signal opened()
signal closed()

func open() -> void:
	visible = true
	animationPlayer.play("open")
	await animationPlayer.animation_finished == "open"
	opened.emit()
	
func close() -> void:
	animationPlayer.play_backwards("open")
	await animationPlayer.animation_finished == "open"
	visible = false
	closed.emit()
