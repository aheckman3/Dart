extends CharacterBody3D

@onready var dodge_detector: Area3D = $DodgeDetector
@onready var mesh: Node3D = $Visuals
@onready var cannon_left: Node3D = $Visuals/CannonLeft
@onready var cannon_right: Node3D = $Visuals/CannonRight

@export var bob_speed := 3.0
@export var bob_height := 0.01
@export var rotate_speed := 20.0
@export var speed := 2
@export var speed_after_time := 3
@export var speed_increase_delay := 45
@export var grow_radius := 4.0
@export var grow_speed := 0.5
@export var max_scale := 5.0
@export var min_scale := 1.0
@export var max_health := 1000
@export var minion_scene : PackedScene
@export var minion_count := 10
@export var minion_spawn_interval := 20.0
@export var dodge_interval := 5.0
@export var dodge_speed := 45.0
@export var dodge_duration := 0.25
@export var dodge_chance := 0.4
@export var hover_height := 10


var health := 500
var has_spawned_minions := false
var minion_spawn_timer := 0.0
var dodge_timer := 0.0
var dodge_time_left := 0.0
var dodge_direction := Vector3.ZERO
var bob_time := 0.0
var player : Node3D = null
var alive_time := 0.0
var original_scale := Vector3.ONE
var dodge_squash := 0.4
var dodge_stretch := 1.5

var base_scale := 1.0
var visual_scale := 1.0
var dodge_start_scale := 1.0

func _enter_tree():
	scale = Vector3.ONE
	print("Boss has Spawned!")
func _ready():
	print("Enemy _ready()")
	player = get_tree().get_first_node_in_group("player")
	dodge_detector.body_entered.connect(_on_dodge_detector_entered)
	var bossmesh := $Visuals/BossMesh
	for i in bossmesh.get_surface_override_material_count():
		var mat: StandardMaterial3D = bossmesh.get_surface_override_material(i)
		
		if mat == null:
			var base_mat : StandardMaterial3D = bossmesh.mesh.surface_get_material(i)
			if base_mat:
				mat = base_mat.duplicate()
				bossmesh.set_surface_override_material(i, mat)
				
		if mat:
			mat.emission_enabled = true
			mat.emission = Color(1, 0, 0, 0.2)
			mat.emission_energy = 5

	
func _physics_process(delta):
	if not player:
		return
		
	var dir = (player.global_position - global_position).normalized()

	velocity = dir * speed
	
	move_and_slide()
	
	
	
	alive_time += delta
	if alive_time >= speed_increase_delay:
		speed = speed_after_time
	
	mesh.look_at(player.global_transform.origin, Vector3.UP)
	var rot = mesh.rotation
	mesh.rotation = Vector3(0, rot.y, 0)


	bob_time += delta
	var bob_offset = sin(bob_time * bob_speed) * bob_height
	global_position.y =  hover_height
	mesh.position.y = bob_offset
	
	mesh.rotation.z = sin(bob_time * 1.5) * deg_to_rad(10)
	mesh.rotation.x = sin(bob_time * 0.7) * deg_to_rad(5)
	
	var dist = global_position.distance_to(player.global_position)
	if dist <= grow_radius:
		base_scale = lerp(base_scale, max_scale, grow_speed * delta)
	else:
		base_scale = lerp(base_scale, min_scale, grow_speed * delta)
		
		
	if dodge_time_left > 0.0:
		dodge_time_left -= delta
		global_position += dodge_direction * dodge_speed * delta

		var t = 1.0 - (dodge_time_left / dodge_duration)
		if t < 0.2:
			var squash_t = t / 0.2
			visual_scale = lerp(dodge_start_scale, dodge_start_scale * dodge_squash, squash_t)
		else:
			var stretch_t = (t - 0.2) / 0.8
			visual_scale = lerp(dodge_start_scale * dodge_squash, dodge_start_scale * dodge_stretch, stretch_t)
	else:
		visual_scale = lerp(visual_scale, base_scale, delta * 8)
	mesh.scale = Vector3(visual_scale, visual_scale, visual_scale)
	
	minion_spawn_timer += delta
	if minion_spawn_timer >= minion_spawn_interval:
		spawn_minions()
		minion_spawn_timer = 0.0
		
		
func spawn_minions():
	if minion_scene == null:
		push_error("Boss: minion_scene not assigned")
		return
		
	for i in range(minion_count):
		var minion = minion_scene.instantiate()
		get_tree().current_scene.add_child(minion)
		
		var cannon = cannon_left if randf() < 0.5 else cannon_right
		
		minion.global_position = cannon.global_position
		
		var launch_speed = randf_range(8.0, 14.0)
		var launch_dir = -cannon.global_transform.basis.y.normalized()
		minion.launch_velocity = launch_dir * launch_speed
		minion.launch_velocity.y = randf_range(-2.0, -6.0)
		
	print("Boss has spawned minions!")
	
func _on_body_entered(body):
	if body.is_in_group("dart"):
		take_damage(body.damage)
		body.queue_free()

	if body.is_in_group("player"):
		body.take_damage(25)

		
func pop():
	GameManager.add_score(100)
	queue_free()
	
func take_damage(amount: int):
	health -= amount
	if health <= 0:
		pop()
		
func start_dodge():
	if not player:
		return
		
	var side = -1 if randf() < 0.5 else 1
	var to_player = (player.global_position - global_position).normalized()
	var perpendicular = Vector3(to_player.z, 0, -to_player.x).normalized()
	
	dodge_direction = perpendicular * side
	dodge_time_left = dodge_duration
	
	dodge_start_scale = visual_scale
	visual_scale = dodge_start_scale * dodge_squash
	
func _on_dodge_detector_entered(body):
	if body.is_in_group("dart"):
		try_dodge()
	
	if body.is_in_group("player"):
		var away = (body.global_position - global_position).normalized()
		var horizontal_strength = 23.0
		var vertical_strength = 12.0
		body.apply_knockback(away, horizontal_strength, vertical_strength)
		
		body.take_damage(25)
func try_dodge():
	if randf() <= dodge_chance:
		start_dodge()
	


func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("dart"):
		take_damage(body.damage)
		body.queue_free()

	if body.is_in_group("player"):
		body.take_damage(25)
		
