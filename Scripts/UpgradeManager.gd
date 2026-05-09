extends Node3D
class TempBuff:
	var time_left : float
	var label : Control
	var remove_func : Callable


@export var buff_label_scene : PackedScene
var fire_rate_multiplier := 1.0
var speed_multiplier := 1.0
var jump_multiplier := 1.0
var damage_multiplier := 1.0

var max_health_bonus := 0 
var armor := 0.0

var active_buffs :={}

func _physics_process(delta):
	for buff_name in active_buffs.keys().duplicate():
		var buff: TempBuff = active_buffs[buff_name]
		
		buff.time_left -= delta
		if buff.label:
			buff.label.get_node("BuffTimer").text = "%.1f" % buff.time_left

		if buff.time_left <= 0:
			buff.remove_func.call()
			if buff.label:
				buff.label.queue_free()
			active_buffs.erase(buff_name)

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
	if active_buffs.has(buff_name):
		var buff: TempBuff = active_buffs[buff_name]
		buff.time_left += duration
		buff.label.get_node("BuffTimer").text = "%.1f" % buff.time_left
		return

	apply_func.call()
	var new_buff = TempBuff.new()
	new_buff.time_left = duration
	new_buff.label = create_buff_label(buff_name, duration)
	new_buff.remove_func = remove_func
	active_buffs[buff_name] = new_buff


func apply_upgrade(upgrade_name: String):
	match upgrade_name:
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
		"explosive_dart":
			apply_temp_buff(
				"explosive_dart",
				10.0,
				func():
					get_parent().get_node("WeaponManager").has_explosive_shot = true,
				func():
					get_parent().get_node("WeaponManager").has_explosive_shot = false)




func create_buff_label(buff_name: String, duration: float) -> Control:
	var ui = get_tree().get_first_node_in_group("ui")
	print("UI found:", ui)
	if not ui:
		push_error("UI node not found in scene tree")
		return null
	print("UI children:", ui.get_children())
	var buff_list = ui.get_node("HUD/BuffList")
	print("BuffList found:", buff_list)
	if not buff_list:
		push_error("BuffList node not found in HUD")
		return null
	var label = buff_label_scene.instantiate()
	print("Buff label instantiated:", label)
	print("Label size:", label.size)
	print("Label global pos:", label.global_position)
	print("Label local pos:", label.position)
	print("Label rect pos:", label.get_rect().position)
	label.get_node("BuffName").text = buff_name.replace("_", " ")
	label.get_node("BuffTimer").text = "%.1f" % duration
	buff_list.add_child(label)
	print("BuffList child count after add:", buff_list.get_child_count())
	return label
	


func remove_buff(buff_name: String):
	match buff_name:
		"pyramid_shot":
			get_parent().get_node("WeaponManager").has_pyramid_shot = false
		"quick_shot":
			remove_quick_shot()
		"speed_boost":
			remove_speed_boost(2.0)
		"jump_boost":
			remove_jump_boost(2.0)
		"explosive_dart":
			get_parent().get_node("WeaponManager").has_explosive_shot = false
