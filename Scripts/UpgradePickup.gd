extends CharacterBody3D

@export var upgrade_name : String

var fall_gravity := -9.8
var friction := 4.0
var launched := false


func _ready() -> void:
	$Detector.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if not launched:
		return
	velocity.y += fall_gravity * delta
	velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	velocity.z = move_toward(velocity.z, 0.0, friction * delta)
	global_translate(velocity * delta)
	move_and_slide()

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return

	var upgrades = body.get_node("UpgradeManager")
	upgrades.apply_upgrade(upgrade_name)

	queue_free()

func launch(dir: Vector3, force: float = 6.0):
	velocity = dir.normalized() * force
	launched = true
