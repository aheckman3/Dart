extends Node

signal score_changed(new_score)
var game_state := "menu"
var score := 0 
var recapture_mouse := false

var sky : Node = null


func _ready():
	game_state = "playing"
	$Ambience.play()
	print(game_state)
	get_tree().node_added.connect(_on_node_added)

	
func _input(event):
	if recapture_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		recapture_mouse = false
		
	if event.is_action_pressed("pause"):
		var ui := get_tree().current_scene.get_node_or_null("GameUI")
		if ui == null:
			return
		
		var settings := ui.get_node("SettingsMenu")
		if settings == null:
			return
	
		if settings.visible:
			settings.visible = false
			get_tree().paused = false
			game_state = "playing"
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			return
		
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
	
func _on_player_died():
	if sky == null:
		return
	
	var start_time: float = sky.current_time
	var end_time: float = 19.0
	var duration := 1.5
	var t := 0.0
	
	while t < duration:
		t += get_process_delta_time()
		var alpha := t / duration
		sky.current_time = lerp(start_time, end_time, alpha)
		await get_tree().process_frame

func _on_node_added(node):
	if node.is_in_group("player"):
		node.player_died.connect(_on_player_died)
	
func register_sky(s):
	sky = s
	
func _on_boss_phase_started():
	#change game music to boss music
	pass
