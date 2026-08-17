extends CanvasLayer


@onready var label = $Control/Label
@onready var bg = $Control/ColorRect

func _ready():
	pass
	
func _enter_tree():
	pass

func show_message(text: String, duration := 2.0):
	label.text = text
	visible = true
	
	var bg_start = bg.color
	bg_start.a = 0.0
	bg.color = bg_start
	
	var label_start = label.modulate
	label_start.a = 0.0
	label.modulate = label_start
	
	var bg_end = bg.color
	bg_end.a = 0.4
	
	var label_end = label.modulate
	label_end.a = 1.0
	
	var tween = create_tween()
	tween.tween_property(bg, "color", bg_end, 0.3)
	tween.tween_property(label, "modulate", label_end, 0.3)
	
	await get_tree().create_timer(duration).timeout
	
	var bg_fade = bg.color
	bg_fade.a = 0.0
	
	var label_fade = label.modulate
	label_fade.a = 0.0
	
	var tween2 = create_tween()
	tween2.tween_property(bg, "color", bg_fade, 0.3)
	tween2.tween_property(label, "modulate", label_fade, 0.3)
	
	await tween2.finished
	visible = false
