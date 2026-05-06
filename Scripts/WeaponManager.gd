extends Node3D


var DartScene := preload("res://Scenes/dart.tscn")
var can_shoot := true
var upgrades

var has_pyramid_shot := false
var has_explosive_shot := false

func _ready() -> void:
	upgrades = get_parent().get_node("UpgradeManager")

func fire(player):
	if not can_shoot:
		return
	can_shoot = false

	if has_pyramid_shot:
		pyramid_shot(player)
	else:
		normal_shot(player)

	start_cooldown()


func normal_shot(player):
	var camera = player.get_node("Head/Camera3D")
	var shoot_point = player.get_node("Head/ShootPoint")
	var forward = -camera.global_transform.basis.z
	var dart = DartScene.instantiate()
	var spawn_transform = shoot_point.global_transform
	spawn_transform.origin += forward * 0.2

	dart.global_transform = spawn_transform
	dart.direction = forward
	get_tree().root.add_child(dart)
	dart.is_explosive = has_explosive_shot

func pyramid_shot(player):
	var camera = player.get_node("Head/Camera3D")
	var shoot_point = player.get_node("Head/ShootPoint")
	var forward = -camera.global_transform.basis.z
	var right = camera.global_transform.basis.x
	var up = camera.global_transform.basis.y

	var offsets = [
		Vector3.ZERO,
		-right * 0.3,
		right * 0.3,
		up * 0.3
	]

	for offset in offsets:
		var dart = DartScene.instantiate()
		var spawn_transform = shoot_point.global_transform
		spawn_transform.origin += forward * 2.0
		spawn_transform.origin += offset

		dart.global_transform = spawn_transform
		dart.direction = forward
		get_tree().root.add_child(dart)
		dart.is_explosive = has_explosive_shot

func explosive_shot():
		has_explosive_shot = true


func start_cooldown():
	var base_cooldown = 0.5
	var final_cooldown = base_cooldown / upgrades.fire_rate_multiplier

	await get_tree().create_timer(final_cooldown).timeout
	can_shoot = true
