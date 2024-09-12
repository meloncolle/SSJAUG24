extends Control

@export var levels_dir: String = "res://_debug/test_level/"
var levels: Array[String] = []

var buttonInstance: Node = null
var buttonBasePath: String = "res://UI/base_button.tscn"

var fullHeight: float = 0

@export var opened: float: set = set_opened
@onready var menu: Control = $MarginContainer
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer


func _init() -> void:
	for file_name in DirAccess.get_files_at(levels_dir):
		if file_name.ends_with(".tscn"):
			levels.append(file_name)
		elif file_name.ends_with(".remap"):
			levels.append(file_name.split(".remap")[0])
			
	fullHeight = 60 * (levels.size() + 1) + 80

func _ready() -> void:
	animationPlayer.play("open")
	for level in levels:
		buttonInstance = ResourceLoader.load(buttonBasePath).instantiate()
		buttonInstance.get_node("Text").text = "[center]%s[/center]" % level.split(".")[0]
		$MarginContainer/VBoxContainer.add_child(buttonInstance)
		
		var lambda = func():
			animationPlayer.play("close")
			await animationPlayer.animation_finished
			queue_free()
			Globals.sceneController.load_level(levels_dir.path_join(level))
		
		buttonInstance.pressed.connect(lambda)

	$MarginContainer/VBoxContainer.move_child($MarginContainer/VBoxContainer/BackButton, -1)

func _on_button_pressed() -> void:
	Globals.sceneController.sfx.UIButtonPress.play()
	animationPlayer.play("close")
	await animationPlayer.animation_finished
	queue_free()
	
func set_opened(v: float) -> void:
	opened = clamp(v, 0, 1)

	menu.size.y = lerpf(0, fullHeight, opened)
	menu.position.y = (get_viewport().get_visible_rect().size.y - menu.size.y) * 0.5
