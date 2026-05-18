extends CharacterBody3D

@onready var enemy_mesh := $"."
@onready var grunt_player = $Grunt
@onready var grunt_timer = $GruntTimer

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
@export var death_sounds: Array[AudioStream]
@export var pop_sounds: Array[AudioStream]
var health := 10
var launch_velocity: Vector3 = Vector3.ZERO


var bob_time := 0.0
var player : Node3D = null
var alive_time := 0.0


func _ready():
	print("Enemy _ready()")
	player = get_tree().get_first_node_in_group("player")


	
func _physics_process(delta):
	if not player:
		return
		
	var chase_dir = (player.global_transform.origin - global_transform.origin).normalized()
	var dir = (player.global_transform.origin - global_transform.origin).normalized()
	
	var collision = get_last_slide_collision()
	if collision:
		var normal = collision.get_normal()
		var dot = chase_dir.dot(normal)

		if dot < -0.2:
			var left = chase_dir.rotated(Vector3.UP, 0.8)
			var right = chase_dir.rotated(Vector3.UP, -0.8)

			if left.dot(normal) > right.dot(normal):
				dir = left
			else:
				dir = right

			dir = chase_dir.lerp(dir, 0.5)
	velocity = dir * speed

	if launch_velocity.length() > 0.01:
		velocity += launch_velocity
		launch_velocity = launch_velocity.move_toward(Vector3.ZERO, delta * 2.0)
	move_and_slide()

	
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

func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("dart"):
		take_damage(body.damage)
		body.queue_free()

	if body.is_in_group("player"):
		body.take_damage(10)
		queue_free()
func pop():
	GameManager.add_score(5)
	play_random_death_sound()
	queue_free()
	
func take_damage(amount):
	health -= amount
	if health <= 0:
		pop()


func _on_grunt_timer_timeout() -> void:
	if not player:
		return
		
	var dist = global_position.distance_to(player.global_position)
	
	if dist < 6.0:
		grunt_player.pitch_scale = randf_range(0.9, 1.1)
		grunt_player.play()
		
	grunt_timer.wait_time = randf_range(1.0, 3.0)
	grunt_timer.start()
	
func play_random_death_sound():
	if death_sounds.is_empty():
		return
		
	var audio = $DeathSounds
	if audio == null:
		return
	var root = get_tree().current_scene
	audio.reparent(root)
	
	audio.stream = death_sounds.pick_random()
	audio.pitch_scale = randf_range(0.9, 1.1)
	audio.play()
	
func play_random_pop():
	if pop_sounds.is_empty():
		return
		
	var pop_audio = $PopSounds
	if pop_audio == null:
		return
	var root = get_tree().current_scene
	pop_audio.reparent(root)
	pop_audio.stream = pop_sounds.pick_random()
	
	pop_audio.pitch_scale = randf_range(0.9, 1.1)
	pop_audio.play()
