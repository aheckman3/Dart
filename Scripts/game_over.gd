extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CenterContainer/VBoxContainer/ScoreLabel.text = "Score: %d" % GameManager.score
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/proto_level.tscn")


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
