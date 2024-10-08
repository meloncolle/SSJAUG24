extends Node

var gameState: Enums.GameState
var sceneInstance: Node = null
var levelPath: String

@onready var startMenu: Control = $Menus/Start
@onready var pauseMenu: Control = $Menus/Pause

@onready var sfx = {
	"UIButtonPress": $Audio/UIButtonPress,
}

func _ready():
	if Globals.ENABLE_COLLISION_DEBUG_IN_EXPORT:
		get_tree().set_debug_collisions_hint(true)
	
	Globals.sceneController = self
	set_state(Enums.GameState.ON_START)
	startMenu.get_node("StartButton").pressed.connect(self._on_press_level)
	startMenu.get_node("CreditsButton").pressed.connect(self._on_press_credits)
	pauseMenu.resumeButton.pressed.connect(self._on_press_resume)
	pauseMenu.submitButton.pressed.connect(self._on_press_resume)
	pauseMenu.restartButton.pressed.connect(self._on_press_restart)
	pauseMenu.quitButton.pressed.connect(self._on_press_quit)
		
	for button in [
		startMenu.get_node("CreditsButton"),
		startMenu.get_node("StartButton"),
		pauseMenu.resumeButton,
		pauseMenu.submitButton,
		pauseMenu.restartButton,
		pauseMenu.quitButton
	]:
		button.pressed.connect(func(): sfx.UIButtonPress.play())

func _input (event: InputEvent):
	if(gameState != Enums.GameState.ON_START && event.is_action_pressed("ui_cancel") && Globals.isPausable):
		get_tree().paused = !get_tree().paused
		Globals.isPausable = false
		match gameState:
			Enums.GameState.IN_GAME:
				set_state(Enums.GameState.PAUSED)
				
			Enums.GameState.PAUSED:
				set_state(Enums.GameState.IN_GAME)
	
func set_state(newState: Enums.GameState):
	match newState:
		Enums.GameState.ON_START:
			startMenu.visible = true
			startMenu.timerActive = true
			pauseMenu.visible = false
			Globals.disableInput = false
			
		Enums.GameState.IN_GAME:
			startMenu.timerActive = false
			startMenu.visible = false
			startMenu.loopVid.stop()
			startMenu.openingVid.stop()
			startMenu.titleMusic.stop()
			pauseMenu.close()
			Globals.disableInput = false
			await pauseMenu.closed
			if sceneInstance != null && sceneInstance.state != Enums.LevelState.DEAD:
				Globals.isPausable = true
			
		Enums.GameState.PAUSED:
			Globals.disableInput = true
			pauseMenu.open()
			await pauseMenu.opened
			Globals.isPausable = true
			
	gameState = newState

func _on_press_level():
	var levelSelect: Node = load("res://UI/menus/level_select.tscn").instantiate()
	startMenu.add_child(levelSelect)
	
func _on_press_credits():
	var levelSelect: Node = load("res://UI/menus/credits.tscn").instantiate()
	startMenu.add_child(levelSelect)
	levelSelect.animationPlayer.play("open")
	
func load_level(path: String):
	levelPath = path
	startMenu.fadeAnimationPlayer.play("fade_to_black")
	$Audio/GolfHitSFX.play()
	await startMenu.fadeAnimationPlayer.animation_finished
	sceneInstance = ResourceLoader.load(levelPath).instantiate()
	await $Audio/GolfHitSFX.finished
	self.add_child(sceneInstance)
	set_state(Enums.GameState.IN_GAME)
	
func _on_press_exit():
	get_tree().quit()
	
func _on_press_resume():
	get_tree().paused = false
	set_state(Enums.GameState.IN_GAME)

func _on_press_restart():
	get_tree().paused = false
	# hope this doesnt screw up
	set_state(Enums.GameState.IN_GAME)
	if (is_instance_valid(sceneInstance)):
		sceneInstance.fadeAnimationPlayer.play_backwards("fade_in")
		await sceneInstance.fadeAnimationPlayer.animation_finished
		sceneInstance.queue_free()
	sceneInstance = ResourceLoader.load(levelPath).instantiate()
	self.add_child(sceneInstance)

func _on_press_quit():
	if (is_instance_valid(sceneInstance)):
		startMenu.go_to_end(true)
		await startMenu.fadeAnimationPlayer.animation_finished
		sceneInstance.queue_free()
	sceneInstance = null
	get_tree().paused = false
	set_state(Enums.GameState.ON_START)
