extends Control

@export var levels_dir: String = "res://_debug/test_level/"
var levels: Array[String] = []

var buttonInstance: Node = null
var buttonBasePath: String = "res://UI/base_button.tscn"

func _init() -> void:
	for file_name in DirAccess.get_files_at("res://_debug/test_level/"):
		if file_name.ends_with(".tscn"):
			levels.append(file_name)
		elif file_name.ends_with(".remap"):
			levels.append(file_name.split(".remap")[0])

func _ready() -> void:
	for level in levels:
		buttonInstance = ResourceLoader.load(buttonBasePath).instantiate()
		buttonInstance.get_node("Text").text = "[center]%s[/center]" % level.split(".")[0]
		$MarginContainer/VBoxContainer.add_child(buttonInstance)
		# todo: GOLF sound effect
		buttonInstance.pressed.connect(_on_button_pressed)
		buttonInstance.pressed.connect(func(): Globals.sceneController.load_level(levels_dir.path_join(level)))

	$MarginContainer/VBoxContainer.move_child($MarginContainer/VBoxContainer/BackButton, -1)

func _on_button_pressed() -> void:
	Globals.sceneController.sfx.UIButtonPress.play()
	queue_free()
