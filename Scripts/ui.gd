extends CanvasLayer

@onready var crosshair = $Crosshair

func set_crosshair_targeted(is_targeted: bool):
	if is_targeted:
		crosshair.dot_color = Color(1, 0.2, 0.2)
	else:
		crosshair.dot_color = Color.WHITE
