extends Node3D

@export var boss_scene: PackedScene
@export var spawn_delay := 0

var has_spawned := false

func _ready():
	spawn_boss_after_delay()
	
func spawn_boss_after_delay():
	await get_tree().create_timer(spawn_delay, false).timeout
	
	if has_spawned:
		return
		
	spawn_boss()
	has_spawned = true
	
func spawn_boss():
	if boss_scene == null:
		push_error("BossSpawner: boss_scene is not assigned!")
		return
		
	var boss = boss_scene.instantiate()
	get_tree().current_scene.add_child(boss)
	boss.global_transform = global_transform
		
	print("Boss Spawned!")
