extends Node

signal score_changed(new_score)
var game_state := "menu"
var score := 0 


func _ready():
	game_state = "playing"
	print(game_state)

	
func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		var fs = DisplayServer.window_get_mode()
		if fs == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
	if Input.is_action_just_pressed("ui_uncapture"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event.is_action_pressed("pause"):
		if game_state == "playing":
			pause_game()
		elif game_state == "paused":
			resume_game()
			
func pause_game():
	game_state = "paused"
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print(game_state)
	
func resume_game():
	game_state = "playing"
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print(game_state)
	
func add_score(amount):
	score += amount
	emit_signal("score_changed", score)
	
func minus_score(amount):
	score -= amount
	emit_signal("score_changed", score)
