extends Node

#----------------CONFIG LOAD/SAVE--------------------#
var data = ConfigFile.new()


func _init() -> void:
	# Load data from a file.
	var err = data.load(Globals.SAVE_PATH)

	# If the file didn't load, ignore it.
	if err != OK:
		print("no conf found")

	# Init volume values
	for key in ["BGM", "SFX"]:
		var val: float = data.get_value("Volume", key, 0.5)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(key), linear_to_db(val))
