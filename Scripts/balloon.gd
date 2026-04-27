extends Area3D

@export var float_speed: float = randf_range(0.3, 1.7)
@export var lifetime: float = 10.0
@export var wobble_amount: float = randf_range(0.3, 1.3)
@export var wobble_speed: float = randf_range(0.4, 1.5)
@export var pop_sounds: Array[AudioStream]

var time_alive := 0.0
var wobble_offset := randf() * 10
var push_velocity : Vector3 = Vector3.ZERO


func _ready():
	var mesh: MeshInstance3D = $MeshInstance3D

	var mat := StandardMaterial3D.new()
	mesh.material_override = mat
	var colors = [
		Color.RED,
		Color.BLUE,
		Color.GREEN,
		Color.YELLOW,
		Color.PINK,
		Color.AQUAMARINE,
		Color.KHAKI
	]
	
	$MeshInstance3D.material_override.albedo_color = colors.pick_random()


func _process(delta):
	if push_velocity.length() > 0.01:
		global_position += push_velocity * delta
		push_velocity = push_velocity.move_toward(Vector3.ZERO, delta * 1.5)
	translate(Vector3(0, float_speed * delta, 0))
	
	var wobble = sin(Time.get_ticks_msec() * 0.001 * wobble_speed + wobble_offset) * wobble_amount
	translate(Vector3(wobble * delta, 0, 0))
	
	var rotation_amount = wobble * randf_range(1.1, 1.7)
	rotate_z(rotation_amount * delta)
	rotate_y(rotation_amount * delta)
	
	
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("dart"):
		pop()
		
	if body.is_in_group("player"):
		var away = (global_position - body.global_position).normalized()
		var push_strength = 3.0
		push_velocity = away * push_strength
		body.apply_balloon_push(-away, 0.5)
		
func play_random_pop():
	if pop_sounds.is_empty():
		return
		
	var audio = $Audio
	audio.stream = pop_sounds.pick_random()
	
	audio.pitch_scale = randf_range(0.9, 1.1)
	audio.play()
	print("POP SOUND CALLED")


func pop():
	play_random_pop()
	GameManager.add_score(1)
	
	var confetti = $Confetti

	
	remove_child(confetti)
	get_tree().current_scene.add_child(confetti)
	confetti.global_transform = global_transform
	confetti.restart()
	await get_tree().create_timer(0.1).timeout
	
	queue_free()
