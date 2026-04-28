extends Control




func _on_resume_pressed() -> void:
	get_tree().paused = false
	GameManager.game_state = "playing"
	print("pressed")


func _on_quit_pressed() -> void:
	get_tree().quit()
