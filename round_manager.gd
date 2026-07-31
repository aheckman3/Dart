extends Node3D

enum Phase { EARLY, MID, BOSS}
var phase := Phase.EARLY

@export var early_spawners: Array[Node3D]
@export var enemy_spawners: Array[Node3D]
@export var boss_spawner: Node3D

@export var boss_time := 10.0
var timer := 0.0

@onready var bossTimer = $bossTimer
@onready var difficultyTimer = $difficultyTimer

signal boss_phase_started
signal difficulty_increased

func _ready():
	start_early_phase()
	bossTimer.wait_time = boss_time
	bossTimer.start()
	
func _process(delta):
	timer += delta
	if timer >= 60.0 and phase == Phase.EARLY:
		start_mid_phase()
		
func start_early_phase():
	phase = Phase.EARLY
	
	for s in early_spawners:
		s.enabled = true
		s.spawn_interval = 0.1
		
	for s in enemy_spawners:
		s.enabled = false
		
	boss_spawner.enabled = false

func boss_defeated():
	print("Boss defeated!")
	#trigger victory screen and UI stuff
	
	
func start_mid_phase():
	phase = Phase.MID
	timer = 0.0
	
	for s in early_spawners:
		s.spawn_interval = 0.001
		
	for s in enemy_spawners:
		s.enabled = true
	print("mid-phase started")
	
func start_boss_phase():
	phase = Phase.BOSS
	print("boss phase started")
	
	for s in early_spawners:
		s.enabled = false
		
	for s in enemy_spawners:
		s.enabled = false
		
	boss_spawner.spawn_once = true
	boss_spawner.enabled = true

	emit_signal("boss_phase_started")

func increase_difficulty():
	for s in early_spawners:
		s.spawn_interval = max(0.5, s.spawn_interval - 0.5)
		
func _on_boss_timer_timeout() -> void:
	start_boss_phase()


func _on_difficulty_timer_timeout() -> void:
	emit_signal("difficulty_increased")
	increase_difficulty()
