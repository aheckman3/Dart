extends Node3D

enum Phase { P1_BALLOONS, P2_ENEMIES, P3_BALLOONS, P4_ENEMIES, P5_BALLOONS, BOSS }
var phase := Phase.P1_BALLOONS

@export var balloon_spawners: Array[Node3D]
@export var enemy_spawners: Array[Node3D]
@export var boss_spawner: Node3D

@export var phase_duration := 45.0
var timer := 0.0

@onready var bossTimer = $bossTimer

signal boss_phase_started

func _ready():
	start_phase(Phase.P1_BALLOONS)
	bossTimer.wait_time = phase_duration * 6
	bossTimer.start()
	
	
func _process(delta):
	timer += delta
	if timer >= phase_duration:
		timer = 0.0
		advance_phase()
		
func advance_phase():
	match phase:
		Phase.P1_BALLOONS:
			start_phase(Phase.P2_ENEMIES)
			
		Phase.P2_ENEMIES:
			start_phase(Phase.P3_BALLOONS)
			
		Phase.P3_BALLOONS:
			start_phase(Phase.P4_ENEMIES)
			
		Phase.P4_ENEMIES:
			start_phase(Phase.P5_BALLOONS)
			
		Phase.P5_BALLOONS:
			start_boss_phase()

func boss_defeated():
	print("Boss defeated!")
	#trigger victory screen and UI stuff
	
	
func start_phase(new_phase):
	phase = new_phase
	
	match new_phase:
		Phase.P1_BALLOONS:
			show_phase_message("Phase 1: Light Balloons")
			enable_balloons(0.05)
			enable_enemies(false)
			
		Phase.P2_ENEMIES:
			show_phase_message("Phase 2: Light Enemies")
			enable_balloons(false)
			enable_enemies(true, 3.0)
			
		Phase.P3_BALLOONS:
			show_phase_message("Phase 3: Heavy Balloons")
			enable_balloons(0.02)
			enable_enemies(false)
			
		Phase.P4_ENEMIES:
			show_phase_message("Phase 4: Heavy Enemies")
			enable_balloons(false)
			enable_enemies(true, 0.5)
			
		Phase.P5_BALLOONS:
			show_phase_message("Phase 5: More Balloons!")
			enable_balloons(0.01)
			enable_enemies(false)
	
	
func start_boss_phase():
	show_phase_message("HERE HE COMES!")
	phase = Phase.BOSS
	print("boss phase started")
	
	enable_balloons(false)
	enable_enemies(false)
	
	boss_spawner.spawn_once = true
	boss_spawner.enabled = true
	boss_spawner.timer = 0.0

	emit_signal("boss_phase_started")

func enable_balloons(interval):
	for s in balloon_spawners:
		if typeof(interval) == TYPE_BOOL and interval == false:
			s.enabled = false
		else:
			s.enabled = true
			s.spawn_interval = interval
			s.timer = 0.0
			
func enable_enemies(enabled, interval := 5.0):
	for s in enemy_spawners:
		s.enabled = enabled
		if enabled:
			s.spawn_interval = interval
			s.timer = 0.0
			
func show_phase_message(text):
	var overlay = get_tree().get_first_node_in_group("overlay")
	if overlay:
		overlay.show_message(text)
