extends Node3D


var fire_rate_multiplier := 1.0
var speed_multiplier := 1.0
var jump_multiplier := 1.0
var damage_multiplier := 1.0

var max_health_bonus := 0 
var armor := 0.0

var active_buffs :={}

func apply_quick_shot():
	fire_rate_multiplier *= 10.0

func remove_quick_shot():
	fire_rate_multiplier /= 10.0

func apply_speed_boost(amount):
	speed_multiplier *= amount

func remove_speed_boost(amount):
	speed_multiplier /= amount

func apply_jump_boost(amount):
	jump_multiplier *= amount

func remove_jump_boost(amount):
	jump_multiplier /= amount


func apply_temp_buff(buff_name: String, duration: float, apply_func: Callable, remove_func: Callable):
	ui_show_buff(buff_name, duration)
	if buff_name in active_buffs:
		return

	apply_func.call()
	active_buffs[buff_name] = true

	await get_tree().create_timer(duration).timeout
	remove_func.call()
	active_buffs.erase(buff_name)

func apply_upgrade(name: String):
	match name:
		"pyramid_shot":
			apply_temp_buff(
				"pyramid_shot", 
				10.0, 
				func():
					get_parent().get_node("WeaponManager").has_pyramid_shot = true,
				func():
					get_parent().get_node("WeaponManager").has_pyramid_shot = false)
		"quick_shot":
			apply_temp_buff(
				"quick_shot", 
				3.0, 
				func():
					apply_quick_shot(),
				func():
					remove_quick_shot())
		"speed_boost":
			apply_temp_buff(
				"speed_boost", 
				5.0, 
				func():
					apply_speed_boost(2.0),
				func():
					remove_speed_boost(2.0))
		"jump_boost":
			apply_temp_buff(
				"jump_boost", 
				5.0, 
				func():
					apply_jump_boost(2.0),
				func():
					remove_jump_boost(2.0))

func ui_show_buff(name: String, duration: float):
	var ui = get_tree().get_first_node_in_group("ui")
	if not ui:
		return
	var buff_list = ui.get_node("BuffList")
	var buff_label_scene = preload("res://Scenes/buff_label.tscn")
	var label = buff_label_scene.instantiate()
	name = name.replace("_", " ")
	label.setup(name, duration)
	buff_list.add_child(label)
	print("Adding buff label:", name)
