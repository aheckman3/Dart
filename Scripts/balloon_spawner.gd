extends Node3D

@export var balloon_scene: PackedScene 
@export var spawn_interval: float =0.1
@export var spawn_area_x: float = 10.0
@export var spawn_area_z: float = 10.0
@export var spawn_height: float = 0.0

var timer := 0.0


func _process(delta):
	timer += delta
	if timer >= spawn_interval:
		timer = 0.0
		spawn_balloon()

func spawn_balloon():
	var balloon = balloon_scene.instantiate()
	
	var x = randf_range(-spawn_area_x, spawn_area_x)
	var z = randf_range(-spawn_area_z, spawn_area_z)
	
	balloon.position = Vector3(x, spawn_height, z)
	
	get_tree().current_scene.add_child(balloon)
	
