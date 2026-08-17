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
var permanent_labels := {}

var speed_boost_stacks := 0
var jump_boost_stacks := 0
var quick_shot_stacks := 0

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
			apply_permanent_upgrade("quick_shot")
			
		"speed_boost":
			apply_permanent_upgrade("speed_boost")
			
		"jump_boost":
			apply_permanent_upgrade("jump_boost")


func apply_permanent_upgrade(upgrade_name: String):
	match upgrade_name:
		"quick_shot":
			fire_rate_multiplier *= 1.02
			quick_shot_stacks += 1
			update_permanent_label("quick_shot", quick_shot_stacks)
		"speed_boost":
			speed_multiplier *= 1.01
			speed_boost_stacks += 1
			update_permanent_label("speed_boost", speed_boost_stacks)
		"jump_boost":
			jump_multiplier *= 1.01
			jump_boost_stacks += 1
			update_permanent_label("jump_boost", jump_boost_stacks)
		"damage_boost":
			damage_multiplier *= 1.05

func update_permanent_label(buff_name: String, stacks: int):
	if permanent_labels.has(buff_name):
		var label = permanent_labels[buff_name]
		label.get_node("BuffName").text = "%s %d" % [buff_name.replace("_", " "), stacks]
	else:
		var label = create_permanent_buff_label(buff_name, stacks)
		permanent_labels[buff_name] = label



func create_buff_label(buff_name: String, duration: float) -> Control:
	var ui = get_tree().get_first_node_in_group("ui")
	if not ui:
		push_error("UI node not found in scene tree")
		return null
	var buff_list = ui.get_node("HUD/BuffList")
	if not buff_list:
		push_error("BuffList node not found in HUD")
		return null
	var label = buff_label_scene.instantiate()
	label.get_node("BuffName").text = buff_name.replace("_", " ")
	label.get_node("BuffTimer").text = "%.1f" % duration
	buff_list.add_child(label)
	return label

func create_permanent_buff_label(buff_name: String, stacks: int) -> Control:
	var ui = get_tree().get_first_node_in_group("ui")
	var buff_list = ui.get_node("HUD/BuffList")
	
	var label = buff_label_scene.instantiate()
	label.get_node("BuffName").text = "%s %d" % [buff_name.replace("_", " "), stacks]
	label.get_node("BuffTimer").visible = false
	buff_list.add_child(label)
	
	return label


func remove_buff(buff_name: String):
	match buff_name:
		"pyramid_shot":
			get_parent().get_node("WeaponManager").has_pyramid_shot = false
