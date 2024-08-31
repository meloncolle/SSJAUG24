extends Node

@export var starting_level: PackedScene = null

var gameState: Enums.GameState
var sceneInstance: Node = null

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
	startMenu.get_node("Panel/VBoxContainer/StartButton").pressed.connect(self._on_press_start)
	startMenu.get_node("Panel/VBoxContainer/ExitButton").pressed.connect(self._on_press_exit)
	pauseMenu.get_node("Panel/VBoxContainer/ResumeButton").pressed.connect(self._on_press_resume)
	pauseMenu.get_node("Panel/VBoxContainer/RestartButton").pressed.connect(self._on_press_restart)
	pauseMenu.get_node("Panel/VBoxContainer/QuitButton").pressed.connect(self._on_press_quit)
	
	for button in [
		startMenu.get_node("Panel/VBoxContainer/StartButton"),
		startMenu.get_node("Panel/VBoxContainer/ExitButton"),
		pauseMenu.get_node("Panel/VBoxContainer/ResumeButton"),
		pauseMenu.get_node("Panel/VBoxContainer/RestartButton"),
		pauseMenu.get_node("Panel/VBoxContainer/QuitButton")
	]:
		button.pressed.connect(func(): sfx.UIButtonPress.play())
	
	if Globals.ENABLE_SKIP_TITLE_SCREEN:
		_on_press_start()

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
			pauseMenu.visible = false
			
		Enums.GameState.PAUSED:
			pauseMenu.visible = true
			Globals.disableInput = true
			
	gameState = newState


func _on_press_start():
	sceneInstance = load(starting_level.resource_path).instantiate()
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
	sceneInstance = load(starting_level.resource_path).instantiate()
	self.add_child(sceneInstance)
	get_tree().paused = false
	set_state(Enums.GameState.IN_GAME)

func _on_press_quit():
	if (is_instance_valid(sceneInstance)):
		sceneInstance.queue_free()
	sceneInstance = null
	get_tree().paused = false
	set_state(Enums.GameState.ON_START)
