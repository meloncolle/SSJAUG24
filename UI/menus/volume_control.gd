extends Control

@onready var BGM_control: VSlider = $BGM
@onready var SFX_control: VSlider = $SFX

@onready var bgm_bus := AudioServer.get_bus_index("BGM")
@onready var sfx_bus := AudioServer.get_bus_index("SFX")

func _ready() -> void:
	BGM_control.value = db_to_linear(AudioServer.get_bus_volume_db(bgm_bus))
	SFX_control.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))

func _on_bgm_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bgm_bus, linear_to_db(value))
	Config.data.set_value("Volume", "BGM", value)
	Config.data.save(Globals.SAVE_PATH)

func _on_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))
	Config.data.set_value("Volume", "SFX", value)
	Config.data.save(Globals.SAVE_PATH)
