extends Node3D


@onready var pause_menu := $"../GameUI/PauseMenu"
@onready var hud := $"../GameUI/HUD"


func _ready():
	GameManager.register_sky($"../Sky3D")
	
func _process(_delta):
	if GameManager.game_state == "paused":
		pause_menu.visible = true
		hud.hide()
	else:
		pause_menu.hide()
		hud.show()
