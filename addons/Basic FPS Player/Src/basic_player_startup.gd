@tool
extends CharacterBody3D

var BasicFPSPlayerScene : PackedScene = preload("basic_player_head.tscn")
var addedHead := false

func _enter_tree():
	if find_child("Head"):
		addedHead = true

	if Engine.is_editor_hint() and not addedHead:
		var s = BasicFPSPlayerScene.instantiate()
		add_child(s)
		s.owner = get_tree().edited_scene_root
		addedHead = true
	print("Player _enter_tree()")
#__________________________________________________________________________________________________#
# PLAYER SETTINGS
#__________________________________________________________________________________________________#
signal player_ready
@export var CAPTURE_ON_START := true

@export_category("Movement")
@export var SPEED := 3.0
@export var ACCEL := 50.0
@export var IN_AIR_SPEED := 3.0
@export var IN_AIR_ACCEL := 5.0
@export var JUMP_VELOCITY := 8.5
@export var SPRINT_SPEED := 8

@export_category("Head Bob")
@export var HEAD_BOB := true
@export var HEAD_BOB_FREQUENCY : float = 0.3
@export var HEAD_BOB_AMPLITUDE : float = 0.02
@export var SPRINT_HEAD_BOB_AMPLITUDE : float = 0.04

@export_category("Mouse")
@export var MOUSE_ACCEL := true
@export var KEY_BIND_MOUSE_SENS := 0.003
@export var KEY_BIND_MOUSE_ACCEL := 50

@export_category ("Keybinds")
@export var KEY_BIND_UP := "move_forward"
@export var KEY_BIND_LEFT := "move_left"
@export var KEY_BIND_RIGHT := "move_right"
@export var KEY_BIND_DOWN := "move_backwards"
@export var KEY_BIND_JUMP := "ui_accept"

@export_category("Advanced")
@export var UPDATE_PLAYER_ON_PHYS_STEP := true

@export_category("Sounds")
@export var footstep_sounds: Array[AudioStream] = []

#__________________________________________________________________________________________________#
#INTERNAL VARIABLES
#__________________________________________________________________________________________________#
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") * 1.3
var speed := SPEED
var accel := ACCEL

var rotation_target_player := 0.0
var rotation_target_head := 0.0
var head_start_pos : Vector3
var tick := 0
var max_health : int = 100
var health : int = 100
var DartScene := preload("res://Scenes/dart.tscn")
var can_shoot := true
var last_bob_sign := 0
var footstep_ready := true
var ui
var shake_strength: float = 0.0
var shake_time: float = 0.0
var shake_decay: float = 5.0
var noise := FastNoiseLite.new()
#__________________________________________________________________________________________________#
# STATE MACHINE
#__________________________________________________________________________________________________#
enum PlayerState { IDLE, WALKING, SPRINTING, JUMPING, FALLING}
var state := PlayerState.IDLE


func _ready():
	if Engine.is_editor_hint():
		return
	if CAPTURE_ON_START:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	head_start_pos = $Head.position
	
	call_deferred("_find_ui")
	emit_signal("player_ready")
	print("Player _ready()")
	
func _find_ui():
	ui = get_tree().current_scene.get_node("UI")

func is_aiming_at_target() -> bool:
	if $Head/RayCast3D.is_colliding():
		var obj = $Head/RayCast3D.get_collider()
		return obj and obj.is_in_group("target")
	return false
#__________________________________________________________________________________________________#
# PROCESSING
#__________________________________________________________________________________________________#
	
func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	
	tick += 1
		
	if UPDATE_PLAYER_ON_PHYS_STEP:
		rotate_player(delta)
	state_machine(delta)
		
	if HEAD_BOB:
		if velocity.length() > 0.1 and is_on_floor():
			head_bob_motion()
		reset_head_bob(delta)
		
	if HEAD_BOB and is_on_floor() and velocity.length() > 0.2:
		check_footstep()
			

func _process(delta):
	if Engine.is_editor_hint():
		return
			
	if not UPDATE_PLAYER_ON_PHYS_STEP:
		rotate_player(delta)
		state_machine(delta)

	if Input.is_action_just_pressed("shoot"):
		shoot()
	if ui:
		ui.set_crosshair_targeted(is_aiming_at_target())
	if shake_strength > 0:
		shake_time += delta * 30.0
		var offset = Vector3(noise.get_noise_1d(shake_time) * shake_strength, noise.get_noise_1d(shake_time + 100) * shake_strength, 0)
		$Head.rotation_degrees += offset
		shake_strength = lerp(shake_strength, 0.0, 5.0 * delta)
	
#__________________________________________________________________________________________________#
# INPUT
#__________________________________________________________________________________________________#
func _input(event):
	if Engine.is_editor_hint():
		return
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		set_rotation_target(event.relative)
		
	if event is InputEventMouseButton and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if Input.is_action_just_pressed("ui_uncapture"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.is_action_just_pressed("shoot"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if Input.is_action_just_pressed("toggle_fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
func set_rotation_target(mouse_motion: Vector2):
	rotation_target_player += -mouse_motion.x * KEY_BIND_MOUSE_SENS
	rotation_target_head += -mouse_motion.y * KEY_BIND_MOUSE_SENS
	rotation_target_head = clamp(rotation_target_head, deg_to_rad(-90), deg_to_rad(90))
	#______________________________________________________________________________________________#
	# ROTATION
	#______________________________________________________________________________________________#
	
func rotate_player(delta):
	if MOUSE_ACCEL:
		quaternion = quaternion.slerp(Quaternion(Vector3.UP, rotation_target_player), KEY_BIND_MOUSE_ACCEL * delta)
		$Head.quaternion = $Head.quaternion.slerp(Quaternion(Vector3.RIGHT, rotation_target_head), KEY_BIND_MOUSE_ACCEL * delta)
	else:
		quaternion = Quaternion(Vector3.UP, rotation_target_player)
		$Head.quaternion = Quaternion(Vector3.RIGHT, rotation_target_head)
#__________________________________________________________________________________________________#
# STATE MACHINE DISPATCHER
#__________________________________________________________________________________________________#
func state_machine(delta):
	match state:
		PlayerState.IDLE:
			state_idle(delta)
		PlayerState.WALKING:
			state_walking(delta)
		PlayerState.SPRINTING:
			state_sprinting(delta)
		PlayerState.JUMPING:
			state_jumping(delta)
		PlayerState.FALLING:
			state_falling(delta)

#__________________________________________________________________________________________________#
# STATE FUNCTIONS
#__________________________________________________________________________________________________#
func state_idle(delta):
	apply_gravity(delta)
	handle_movement(delta)
	
	if not is_on_floor():
		state = PlayerState.FALLING
		
	if is_moving():
		state = PlayerState.WALKING
		
	if Input.is_action_just_pressed(KEY_BIND_JUMP):
		jump()
		state = PlayerState.JUMPING
		
func state_walking(delta):
	apply_gravity(delta)
	handle_movement(delta)
	
	if not is_on_floor():
		state = PlayerState.FALLING
		return
		
	if Input.is_action_pressed("sprint"):
		state = PlayerState.SPRINTING
		return
	
	if not is_moving():
		state = PlayerState.IDLE
		return
		
	if Input.is_action_just_pressed(KEY_BIND_JUMP):
		jump()
		state = PlayerState.JUMPING
		
func state_sprinting(delta):
	speed = SPRINT_SPEED
	apply_gravity(delta)
	handle_movement(delta)
	
	if not Input.is_action_pressed("sprint"):
		speed = SPEED
		state = PlayerState.WALKING
		return
		
	if not is_moving():
		speed = SPEED
		state = PlayerState.IDLE
		return
		
	if not is_on_floor():
		state = PlayerState.FALLING
		return
		
	if Input.is_action_just_pressed(KEY_BIND_JUMP):
		jump()
		state = PlayerState.JUMPING
		
func state_jumping(delta):
	apply_gravity(delta)
	handle_movement(delta)
	
	if velocity.y < 0:
		state = PlayerState.FALLING
		
func state_falling(delta):
	apply_gravity(delta)
	handle_movement(delta)
		
	if is_on_floor():
		state = PlayerState.IDLE
#__________________________________________________________________________________________________#
# MOVEMENT HELPERS
#__________________________________________________________________________________________________#

func is_moving() -> bool:
	return Input.is_action_pressed(KEY_BIND_UP) or Input.is_action_pressed(KEY_BIND_DOWN) or Input.is_action_pressed(KEY_BIND_LEFT) or Input.is_action_pressed(KEY_BIND_RIGHT)
	
func handle_movement(delta):
	var input_dir = Input.get_vector(KEY_BIND_LEFT, KEY_BIND_RIGHT, KEY_BIND_UP, KEY_BIND_DOWN)
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	velocity.x = move_toward(velocity.x, direction.x * speed, accel * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, accel * delta)
	
	move_and_slide()
	
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		
func jump():
	velocity.y = JUMP_VELOCITY
#__________________________________________________________________________________________________#
# HEAD BOB
#__________________________________________________________________________________________________#

func head_bob_motion():
	var pos = Vector3.ZERO
	pos.y += sin(tick * HEAD_BOB_FREQUENCY) * HEAD_BOB_AMPLITUDE
	pos.x += cos(tick * HEAD_BOB_FREQUENCY/2) * HEAD_BOB_AMPLITUDE * 2
	$Head.position += pos
	
func reset_head_bob(delta):
	if $Head.position == head_start_pos:
		pass
	$Head.position = lerp($Head.position, head_start_pos, 2 * (1 / HEAD_BOB_FREQUENCY) * delta)
#__________________________________________________________________________________________________#
# SHOOTING
#__________________________________________________________________________________________________#
func shoot():
	if not can_shoot:
		return
	can_shoot = false
	
	var camera = $Head/Camera3D
	var shoot_point = $Head/ShootPoint
	
	var dart = DartScene.instantiate()
	dart.global_transform = shoot_point.global_transform
	dart.direction = -camera.global_transform.basis.z
	
	get_tree().current_scene.add_child(dart)
	
	start_shoot_cooldown()
	
func start_shoot_cooldown():
	await get_tree().create_timer(0.5).timeout
	can_shoot = true
	
	can_shoot
#__________________________________________________________________________________________________#
# Audio
#__________________________________________________________________________________________________#

func check_footstep():
	var bob_value = sin(tick * HEAD_BOB_FREQUENCY)
	var bob_sign = sign(bob_value)
	
	if bob_sign < 0 and last_bob_sign >= 0 and footstep_ready:
		play_footstep()
		footstep_ready = false
	if bob_sign > 0:
		footstep_ready = true
	last_bob_sign = bob_sign
	
func play_footstep():
	if footstep_sounds.is_empty():
		return
	var audio = $FootstepAudio
	audio.stream = footstep_sounds.pick_random()
	
	var base_pitch = 1.3 if state == PlayerState.SPRINTING else 1.0
	audio.pitch_scale = base_pitch * randf_range(0.95, 1.05)
	
	audio.play()
	
#______________________________________________________________________________#
# COMBAT
#______________________________________________________________________________#

func take_damage(amount):
	print("Player took damage:", amount)

	health -= amount
	health = clamp(health, 0, max_health)
	
	var ui = get_tree().get_first_node_in_group("ui")
	ui.set_health(health)
	
	ui.flash_damage()
	camera_shake(2)
	
func camera_shake(amount := 0.2):
	var shake_time := 0.0
	shake_strength = amount
	shake_time = 0.0
	
	
