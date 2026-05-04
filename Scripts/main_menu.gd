extends Control



func _ready() -> void:
	print("VIEWPORT TYPE:", get_viewport())

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	await Transition.fade_out()
	get_tree().change_scene_to_file("res://Scenes/proto_level.tscn")
	await Transition.fade_in()
