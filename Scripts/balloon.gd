class_name Balloon
extends Area3D 

@onready var confetti = $Confetti

@export var float_speed: float = randf_range(0.3, 1.7)
@export var lifetime: float = 10.0
@export var wobble_amount: float = randf_range(0.3, 1.3)
@export var wobble_speed: float = randf_range(0.4, 1.5)
@export var pop_sounds: Array[AudioStream]
@export var menu_mode := false
@export var seperation_radius := 3
@export var serperation_strength := 2.0
@export var upgrade_pickup_scene : PackedScene
@export var chosen_upgrade : String 
@export var possible_drops := ["pyramid_shot", "quick_shot", "speed_boost", "jump_boost", "explosive_dart"]
@export var drop_chance := 0.25
var time_alive := 0.0
var wobble_offset := randf() * 10
var push_velocity : Vector3 = Vector3.ZERO
var popped := false


func _ready():
	var mesh: MeshInstance3D = $Sphere

	var mat := StandardMaterial3D.new()
	mesh.material_override = mat

	
	$Sphere.material_override.albedo_color = get_vibrant_colors()
	mat.metallic = 0.0
	mat.roughness = 0.1
	mat.specular = 1.0
	mat.clearcoat = 1.0
	mat.clearcoat_roughness = 0.05

	if menu_mode:
		var s = randf_range(1.0, 3.0)
		scale = Vector3(s, s, s)
		lifetime = randf_range(2.0, 6.0)
		confetti.position = Vector3(0, .2, 0)
		$Audio.volume_db = -10



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
		if menu_mode:
			pop()
		else:
			queue_free()

	if menu_mode:
		apply_seperation(delta)

func _on_body_entered(body: Node3D) -> void:
	if menu_mode:
		return

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
	if popped:
		return
	popped = true

	if not menu_mode:
		GameManager.add_score(1)

	
	play_random_pop()

	
	remove_child(confetti)
	var parent_3d = get_parent()
	parent_3d.add_child(confetti)
	confetti.global_transform = global_transform
	confetti.restart()
	await get_tree().create_timer(0.1).timeout
	if randf() <= drop_chance and not menu_mode:
		var pickup = upgrade_pickup_scene.instantiate()
		chosen_upgrade = possible_drops.pick_random()
		pickup.upgrade_name = chosen_upgrade
		pickup.global_transform = global_transform

		get_tree().current_scene.add_child(pickup)

		var dir = Vector3(randf_range(-1, 1), randf_range(0.5, 1.5), randf_range(-1, 1))

		pickup.launch(dir, 6.0)
	
	queue_free()

func set_menu_mode(value: bool) -> void:
	menu_mode = value


func apply_seperation(delta):
	var bodies = get_overlapping_bodies()
	for b in bodies:
		if b is Balloon:
			var dir = (global_position - b.global_position)
			var dist = dir.length()
			if dist < seperation_radius and dist > 0.01:
				var push = dir.normalized() * (seperation_radius - dist) * serperation_strength
				global_position += push * delta

func get_vibrant_colors() -> Color:
	var h = randf()
	var s = randf_range(0.8, 1.0)
	var v = randf_range(0.9, 1.0)
	return Color.from_hsv(h, s, v)