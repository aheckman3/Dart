extends Area3D

@onready var enemy_mesh := $"."
@export var bob_speed := 3.0
@export var bob_height := 0.01
@export var rotate_speed := 20.0
@export var speed := randf_range(2.5, 4.5)
@export var speed_after_time := randf_range(5.0, 7.0)
@export var speed_increase_delay := 15.0
@export var grow_radius := 4.0
@export var grow_speed := 0.5
@export var max_scale := 5.0
@export var min_scale := 1.0
@export var max_health := 10
var health := 10
var launch_velocity: Vector3 = Vector3.ZERO


var bob_time := 0.0
var player : Node3D = null
var alive_time := 0.0
func _enter_tree():
	print("Enemy root entered tree:", self)

func _ready():
	print("Enemy _ready()")
	player = get_tree().get_first_node_in_group("player")
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	
func _physics_process(delta):
	if not player:
		return
		
	var dir = (player.global_position - global_position).normalized()
	global_position += dir * speed * delta
	
	alive_time += delta
	if alive_time >= speed_increase_delay:
		speed = speed_after_time
	
	enemy_mesh.look_at(player.global_transform.origin, Vector3.UP)
	var rot = enemy_mesh.rotation
	enemy_mesh.rotation = Vector3(0, rot.y, 0)


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
	
	if launch_velocity.length() > 0.01:
		global_position += launch_velocity * delta
		launch_velocity = launch_velocity.move_toward(Vector3.ZERO, delta * 2.0)
		
func _on_body_entered(body):
	if body.is_in_group("dart"):
		take_damage(body.damage)
		body.queue_free()

	if body.is_in_group("player"):
		body.take_damage(10)
		queue_free()
		
func pop():
	GameManager.add_score(5)
	queue_free()
	
func take_damage(amount):
	health -= amount
	if health <= 0:
		pop()
