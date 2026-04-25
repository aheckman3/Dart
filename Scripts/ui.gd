extends CanvasLayer

@onready var score_label: Label = $ScoreLabel
@onready var crosshair = $Crosshair
@onready var damage_flash = $DamageFlash
@onready var health_bar: TextureProgressBar = $HealthBarContainer/HealthBar
@onready var health_bar_container = $HealthBarContainer
var health_bar_original_pos := Vector2.ZERO
var displayed_health := 100.0
var score := 0
var displayed_score := 0
func _ready():
	health_bar_original_pos = health_bar_container.position
	health_bar.max_value = 100
	health_bar.value = displayed_health
	print("READY BAR:", health_bar.value, "/", health_bar.max_value)
	
	GameManager.connect("score_changed", Callable(self, "update_score"))

func set_health(new_health):
	displayed_health = float(new_health)

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
	
	if displayed_health == 0 and health_bar.value < 0.5:
		health_bar.value = 0
	var t = health_bar.value / health_bar.max_value
	var hue = lerp(0.0, 0.40, t)
	var brightness = lerp(0.6, 1.0, t)
	var saturation = lerp(1.5, 0.7, t)
	health_bar.tint_progress = Color.from_hsv(hue, saturation, brightness)
	
	score_label.text = "Score: %d" % int(displayed_score)
	
func shake_health_bar():
	var tween = create_tween()
	var health_bar_offset = Vector2(randf_range(-50, 50), 0)
	
	tween.tween_property(health_bar_container, "position", health_bar_original_pos + health_bar_offset, 0.05)
	tween.tween_property(health_bar_container, "position", health_bar_original_pos, 0.1)
	
func update_score(target_score):
	var tween = create_tween()
	tween.tween_property(self, "displayed_score", target_score, 0.3)
	
	var bulge = create_tween()
	bulge.tween_property(score_label, "scale", Vector2(1.3, 1.3), 0.1)
	bulge.tween_property(score_label, "scale", Vector2(1, 1), 0.1)
	
	var shake = create_tween()
	shake.tween_property(score_label, "position:x", score_label.position.x + 6, 0.2)
	shake.tween_property(score_label, "position:x", score_label.position.x, 0.05)
	


	
