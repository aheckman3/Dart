extends Node3D

@onready var pause_menu: Control = $PauseMenu
@onready var hud: CanvasLayer = $"../UI"

func _ready():
	pass
	
func _process(_delta):
	if GameManager.game_state == "paused":
		pause_menu.show()
		hud.hide()
	else:
		pause_menu.hide()
		hud.show()
