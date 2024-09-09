extends Control

@export var levels_dir: String = "res://_debug/test_level/"
var levels: Array[String] = []

func _init() -> void:
	for file_name in DirAccess.get_files_at("res://_debug/test_level/"):
		if file_name.ends_with(".tscn"):
			levels.append(file_name)
		elif file_name.ends_with(".remap"):
			levels.append(file_name.split(".remap")[0])

func _ready() -> void:
	for level in levels:
		var button = Button.new()
		button.text = level.split(".")[0]
		$Panel/VBoxContainer.add_child(button)
		button.pressed.connect(_on_button_pressed)
		button.pressed.connect(func(): Globals.sceneController.load_level(levels_dir.path_join(level)))

	$Panel/VBoxContainer.move_child($Panel/VBoxContainer/BackButton, -1)


func _on_button_pressed() -> void:
	Globals.sceneController.sfx.UIButtonPress.play()
	queue_free()
