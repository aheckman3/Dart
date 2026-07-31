extends Control

@onready var anim = $AnimationPlayer

func _ready() -> void:
	$ColorRect.modulate.a = 0.0
	
func fade_out():
	anim.play("fade_out")
	await anim.animation_finished

func fade_in():
	anim.play("fade_in")
	await anim.animation_finished
