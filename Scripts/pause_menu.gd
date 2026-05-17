extends Control


func _ready() -> void:
	visible = false

func _on_resume_pressed() -> void:
	get_tree().paused = false
	GameManager.game_state = "playing"



func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_settings_pressed() -> void:
	visible = false
	get_parent().get_node("SettingsMenu").opened_from = "pause"
	get_parent().get_node("SettingsMenu").visible = true
