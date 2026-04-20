extends Area3D

@onready var enemy_mesh := $"."
@export var bob_speed := 3.0
@export var bob_height := 0.25
@export var rotate_speed := 20.0
@export var speed := 1.5
@export var speed_after_time := 3.0
@export var speed_increase_delay := 15.0
var bob_time := 0.0
var player : Node3D = null
var alive_time := 0.0
func _enter_tree():
	print("Enemy root entered tree:", self)

func _ready():
	print("Enemy _ready()")
	player = get_tree().current_scene.get_node("player")
	connect("body_entered", Callable(self, "_on_body_entered"))
	
func _physics_process(delta):
	if not is_inside_tree():
		return
	if not player:
		return
		
	var dir = (player.global_position - global_position).normalized()
	global_position += dir * speed * delta
	
	alive_time += delta
	if alive_time >= speed_increase_delay:
		speed = speed_after_time
	
	bob_time += delta
	var bob_offset = sin(bob_time * bob_speed) * bob_height
	global_position.y += bob_offset * delta
	
	rotation.z = sin(bob_time * 1.5) * deg_to_rad(10)
	rotation.x = sin(bob_time * 0.7) * deg_to_rad(5)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		enemy_mesh.look_at(player.global_transform.origin, Vector3.UP)
	var rot = enemy_mesh.rotation
	enemy_mesh.rotation = Vector3(0, rot.y, 0)
	
func _on_body_entered(body):
	if body.is_in_group("dart"):
		pop()

	if body.is_in_group("player"):
		body.take_damage(10)
		pop()
		
func pop():
	queue_free()
