extends Node3D

@onready var pause_menu: Control = $UI/PauseMenu

func _ready():
	pause_menu.visible = false
	
func _process(_delta):
	if GameManager.game_state == "paused":
		pause_menu.show()
	else:
		pause_menu.hide()
