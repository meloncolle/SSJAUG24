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
	#startMenu.get_node("Panel/VBoxContainer/StartButton").pressed.connect(self._on_press_start)
	startMenu.get_node("Panel/VBoxContainer/LevelButton").pressed.connect(self._on_press_level)
	startMenu.get_node("Panel/VBoxContainer/ExitButton").pressed.connect(self._on_press_exit)
	pauseMenu.resumeButton.pressed.connect(self._on_press_resume)
	pauseMenu.submitButton.pressed.connect(self._on_press_resume)
	pauseMenu.restartButton.pressed.connect(self._on_press_restart)
	pauseMenu.quitButton.pressed.connect(self._on_press_quit)
		
	for button in [
		startMenu.get_node("Panel/VBoxContainer/LevelButton"),
		startMenu.get_node("Panel/VBoxContainer/ExitButton"),
		pauseMenu.resumeButton,
		pauseMenu.submitButton,
		pauseMenu.restartButton,
		pauseMenu.quitButton
	]:
		button.pressed.connect(func(): sfx.UIButtonPress.play())

func _input (event: InputEvent):
	if(gameState != Enums.GameState.ON_START && event.is_action_pressed("ui_cancel")):
		get_tree().paused = !get_tree().paused
		
		match gameState:
			Enums.GameState.IN_GAME:
				set_state(Enums.GameState.PAUSED)
				
			Enums.GameState.PAUSED:
				set_state(Enums.GameState.IN_GAME)
	
func set_state(newState: Enums.GameState):
	match newState:
		Enums.GameState.ON_START:
			startMenu.visible = true
			pauseMenu.visible = false
			Globals.disableInput = false
			
		Enums.GameState.IN_GAME:
			startMenu.visible = false
			pauseMenu.close()
			await pauseMenu.closed
			Globals.disableInput = false
			
		Enums.GameState.PAUSED:
			Globals.disableInput = true
			pauseMenu.open()
			await pauseMenu.opened
			
	gameState = newState

func _on_press_level():
	var levelSelect: Node = load("res://UI/menus/level_select.tscn").instantiate()
	$Menus.add_child(levelSelect)
	
func load_level(path: String):
	levelPath = path
	sceneInstance = load(levelPath).instantiate()
	self.add_child(sceneInstance)
	set_state(Enums.GameState.IN_GAME)
	
func _on_press_exit():
	get_tree().quit()
	
func _on_press_resume():
	get_tree().paused = false
	set_state(Enums.GameState.IN_GAME)

func _on_press_restart():
	if (is_instance_valid(sceneInstance)):
		sceneInstance.queue_free()
	sceneInstance = load(levelPath).instantiate()
	self.add_child(sceneInstance)
	get_tree().paused = false
	set_state(Enums.GameState.IN_GAME)

func _on_press_quit():
	if (is_instance_valid(sceneInstance)):
		sceneInstance.queue_free()
	sceneInstance = null
	get_tree().paused = false
	set_state(Enums.GameState.ON_START)
