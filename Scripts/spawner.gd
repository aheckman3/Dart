extends Node3D

@export var scene_to_spawn: PackedScene
@export var spawn_interval := 5.0
@export var spawn_once := false
@export var start_delay := 0.0
@export var enabled := true
@export var spawn_radius := 0.0

var timer := 0.0
var has_spawned := false

func _ready():
	timer = -start_delay 
	
func _physics_process(delta):
	if not enabled:
		return
		
	if spawn_once and has_spawned:
		return
		
	timer += delta
	if timer >= spawn_interval:
		spawn()
		timer = 0.0
		has_spawned = true
		
func spawn():
	if scene_to_spawn == null:
		push_error("Spawner has no scene_to_spawn assigned!")
		return
		
	var inst = scene_to_spawn.instantiate()
	get_tree().current_scene.add_child(inst)
	
	var offset = Vector3.ZERO
	if spawn_radius > 0.0:
		var angle = randf() * TAU
		var dist = randf() * spawn_radius
		offset = Vector3(cos(angle) * dist, 0, sin(angle) * dist)
	inst.global_transform.origin = global_transform.origin + offset
		
