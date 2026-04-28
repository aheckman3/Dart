extends Area3D

@onready var dodge_detector: Area3D = $DodgeDetector
@onready var first_boss_mesh: Area3D = $"."
@export var bob_speed := 3.0
@export var bob_height := 0.01
@export var rotate_speed := 20.0
@export var speed := 1
@export var speed_after_time := 3
@export var speed_increase_delay := 45
@export var grow_radius := 4.0
@export var grow_speed := 0.5
@export var max_scale := 5.0
@export var min_scale := 1.0
@export var max_health := 100
@export var minion_scene : PackedScene
@export var minion_count := 10
@export var minion_spawn_interval := 20.0
@export var dodge_interval := 5.0
@export var dodge_speed := 20.0
@export var dodge_duration := 0.25
@export var dodge_chance := 0.4
var health := 100
var has_spawned_minions := false
var minion_spawn_timer := 0.0
var dodge_timer := 0.0
var dodge_time_left := 12.0
var dodge_direction := Vector3.ZERO



var bob_time := 0.0
var player : Node3D = null
var alive_time := 0.0
func _enter_tree():
	print("Enemy root entered tree:", self)

func _ready():
	print("Enemy _ready()")
	player = get_tree().get_first_node_in_group("player")
	connect("body_entered", Callable(self, "_on_body_entered"))
	dodge_detector.body_entered.connect(_on_dodge_detector_entered)
	
func _physics_process(delta):
	if not player:
		return
		
	var dir = (player.global_position - global_position).normalized()
	global_position += dir * speed * delta
	
	alive_time += delta
	if alive_time >= speed_increase_delay:
		speed = speed_after_time
	
	first_boss_mesh.look_at(player.global_transform.origin, Vector3.UP)
	var rot = first_boss_mesh.rotation
	first_boss_mesh.rotation = Vector3(0, rot.y, 0)


	bob_time += delta
	var bob_offset = sin(bob_time * bob_speed) * bob_height
	global_position.y += bob_offset
	
	rotation.z = sin(bob_time * 1.5) * deg_to_rad(10)
	rotation.x = sin(bob_time * 0.7) * deg_to_rad(5)
	
	var dist = global_position.distance_to(player.global_position)
	if dist <= grow_radius:
		var new_scale = lerp(scale.x, max_scale, grow_speed * delta)
		scale = Vector3(new_scale, new_scale, new_scale)
	else:
		var new_scale = lerp(scale.x, min_scale, grow_speed * delta)
		scale = Vector3(new_scale, new_scale, new_scale)
		
	minion_spawn_timer += delta
	if minion_spawn_timer >= minion_spawn_interval:
		spawn_minions()
		minion_spawn_timer = 0.0

		
	if dodge_time_left > 0.0:
		dodge_time_left -= delta
		global_position += dodge_direction * dodge_speed * delta
		return
		
		
		
func spawn_minions():
	if minion_scene == null:
		push_error("Boss: minion_scene not assigned")
		return
	for i in range(minion_count):
		var minion = minion_scene.instantiate()
		get_tree().current_scene.add_child(minion)
		
		var angle = randf() * TAU
		var radius = 3.0
		var offset = Vector3(cos(angle), 0, sin(angle)) * radius
		
		minion.global_position = global_position + offset
		
		var launch_speed = randf_range(3.0, 10.0)
		var launch_dir = offset.normalized()
		minion.launch_velocity = launch_dir * launch_speed
		minion.launch_velocity.y = randf_range(1.0, 4.0)
		
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
	
