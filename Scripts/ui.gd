extends CanvasLayer

@onready var crosshair = $Crosshair
@onready var damage_flash = $DamageFlash
@onready var health_bar: TextureProgressBar = $HealthBar
var health_bar_original_pos := Vector2.ZERO
var displayed_health := 100.0

func _ready():
	health_bar_original_pos = health_bar.position

func set_health(new_health):
	displayed_health = float(new_health)
	if displayed_health == 0 and health_bar.value < 0.5:
		health_bar.value = 0
	shake_health_bar()

	print(displayed_health)
func set_crosshair_targeted(is_targeted: bool):
	if is_targeted:
		crosshair.dot_color = Color(1, 0.2, 0.2)
	else:
		crosshair.dot_color = Color.WHITE

func flash_damage():
	damage_flash.modulate = Color(1, 0, 0, 0.4)
	damage_flash.show()
	damage_flash.create_tween().tween_property(damage_flash, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _process(delta):
	health_bar.value = move_toward(health_bar.value, displayed_health, 60 * delta)
	
	var t = health_bar.value / health_bar.max_value
	health_bar.tint_progress = Color(1.0 - t, t, 0.2)
	
func shake_health_bar():
	var tween = create_tween()
	var offset = Vector2(randf_range(-50, 50), 0)
	
	tween.tween_property(health_bar, "position", health_bar_original_pos + offset, 0.05)
	tween.tween_property(health_bar, "position", health_bar_original_pos, 0.1)
