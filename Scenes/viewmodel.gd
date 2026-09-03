extends Node3D

@onready var anim = $arms_rig/AnimationPlayer


func _ready() -> void:
	anim.play("guard_idle")

func play_throw():
	anim.play("Throw")
	await anim.animation_finished
	anim.play("guard_idle")
