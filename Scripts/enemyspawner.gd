extends Node3D

@export var spawn_radius := 40.0
@export var spawn_interval := 3.0
@export var enemy_scene : PackedScene

var player : CharacterBody3D

func _ready():
	var p = get_tree().current_scene.get_node("player")
	p.player_ready.connect(_init_spawner)
	
func _init_spawner():
	await get_tree().process_frame
	await get_tree().process_frame
	player = get_tree().current_scene.get_node("player")
	spawn_loop()
	
func spawn_loop():
	while true:
		await get_tree().create_timer(spawn_interval, false).timeout
		spawn_enemy()
		
func spawn_enemy():
	print("Spawner: spawning enemy")
	if not player:
		print("No player found, skipping spawn")
		return
		
	var angle = randf() * TAU
	var offset = Vector3(cos(angle), 0, sin(angle)) * spawn_radius
	var spawn_pos = player.global_position + offset
	
	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawn_pos
