extends CharacterBody3D

@export var upgrade_name : String

var fall_gravity := -20
var friction := 1.0
var launched := false
var spin_velocity := Vector3.ZERO
var spin_friction := 3.0


func _ready() -> void:
	$Detector.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if not launched:
		return
	velocity.y += fall_gravity * delta
	velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	velocity.z = move_toward(velocity.z, 0.0, friction * delta)
	move_and_slide()
	if not is_on_floor():
		rotate_x(spin_velocity.x * delta)
		rotate_y(spin_velocity.y * delta)
		rotate_z(spin_velocity.z * delta)

		spin_velocity = spin_velocity.move_toward(Vector3.ZERO, spin_friction * delta)
		return

	if is_on_floor():
		var current_y = rotation.y
		var upright_basis = Basis().rotated(Vector3.UP, rotation.y)
		global_transform.basis = global_transform.basis.slerp(upright_basis, delta * 6.0)

		spin_velocity.x = move_toward(spin_velocity.x, 0.0, 10 * delta)
		spin_velocity.z = move_toward(spin_velocity.z, 0.0, 10 * delta)

		rotate_y(spin_velocity.y * 2 * delta)
		spin_velocity.y = move_toward(spin_velocity.y, 0.0, 0.2 * delta)
		return

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return

	var upgrades = body.get_node("UpgradeManager")
	upgrades.apply_upgrade(upgrade_name)

	queue_free()

func launch(dir: Vector3, force: float = 6.0):
	velocity = dir.normalized() * force
	launched = true

	spin_velocity = Vector3(randf_range(-10, 10), randf_range(-10, 10), randf_range(-10, 10))
	$Fire.emitting = true
