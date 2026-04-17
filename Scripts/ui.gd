extends CanvasLayer

@onready var crosshair = $Crosshair
@onready var damage_flash = $DamageFlash

func set_crosshair_targeted(is_targeted: bool):
	if is_targeted:
		crosshair.dot_color = Color(1, 0.2, 0.2)
	else:
		crosshair.dot_color = Color.WHITE

func flash_damage():
	damage_flash.modulate = Color(1, 0, 0, 0.4)
	damage_flash.show()
	damage_flash.create_tween().tween_property(damage_flash, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
