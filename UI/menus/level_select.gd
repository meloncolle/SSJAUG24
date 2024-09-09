extends Control

@export var levels_dir: String = "res://_debug/test_level/"
var levels: Array[String] = []

func _init() -> void:
	var dir = DirAccess.open(levels_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() && file_name.ends_with(".tscn"):
				levels.append(file_name)
			file_name = dir.get_next()

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
