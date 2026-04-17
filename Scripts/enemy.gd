extends Area3D

@export var speed := 1.5
var player : Node3D = null

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
	
func _on_body_entered(body):
	if body.is_in_group("dart"):
		pop()

	if body.is_in_group("player"):
		body.take_damage(10)
		pop()
		
func pop():
	queue_free()
