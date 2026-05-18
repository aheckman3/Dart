extends Control


@onready var volume_slider = $VBoxContainer/Volumeslider
@onready var fullscreen_toggle = $VBoxContainer/Fullscreentoggle
@onready var sensitivity_slider = $VBoxContainer/Sensitivityslider

var config := ConfigFile.new()
var config_path := "user://settings.cfg"
var opened_from := "pause"

func _ready() -> void:
	load_settings()




	volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)

func load_settings() -> void:
	var err = config.load(config_path)
	if err != OK:
		return
	
	volume_slider.value = config.get_value("audio", "volume", 0.8)
	fullscreen_toggle.button_pressed = config.get_value("video", "fullscreen", false)
	sensitivity_slider.value = config.get_value("controls", "sensitivity", 1.0)

	AudioServer.set_bus_volume_db(0, linear_to_db(volume_slider.value))
	
	var mode = DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen_toggle.button_pressed else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)

func save_setting():
	config.set_value("audio", "volume", volume_slider.value)
	config.set_value("video", "fullscreen", fullscreen_toggle.button_pressed)
	config.set_value("controls", "sensitivity", sensitivity_slider.value)
	config.save(config_path)

func _on_volume_changed(value):
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	save_setting()

func _on_fullscreen_toggled(pressed):
	var mode = DisplayServer.WINDOW_MODE_FULLSCREEN if pressed else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	save_setting()

func _on_sensitivity_changed(value):
	save_setting()
	var player = get_tree().current_scene.get_node("player")
	if player:
		player.sensitivity = value


func _on_back_pressed() -> void:
	visible = false
	if opened_from == "pause":
		get_parent().get_node("PauseMenu").visible = true

	elif opened_from == "main":
		get_parent().visible = true
