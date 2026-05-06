extends Area3D

@export var upgrade_name : String

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return

	var upgrades = body.get_node("UpgradeManager")
	upgrades.apply_upgrade(upgrade_name)

	queue_free()
