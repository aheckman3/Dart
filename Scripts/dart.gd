extends RigidBody3D

@export var speed := 45
@export var lifetime := 15.0
@export var damage := 10


var stuck := false
var direction: Vector3 = Vector3.ZERO

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	if direction != Vector3.ZERO:
		linear_velocity = direction.normalized() * speed

	await get_tree().create_timer(lifetime).timeout
	queue_free()
	
	print("Dart loaded from:", get_stack())

func _physics_process(_delta):
	if stuck:
		return

func _integrate_forces(state):
	if stuck:
		return
		
	if state.get_contact_count() > 0:
		stick_to_surface(state)



func stick_to_surface(state):

	stuck = true
	sleeping = true
	freeze = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	var world_pos = state.get_contact_local_position(0)
	var world_normal = state.get_contact_local_normal(0)
	var collider_rid = state.get_contact_collider(0)
	var offset := -0.1
	world_pos -= world_normal * offset
	
	var collider_id = PhysicsServer3D.body_get_object_instance_id(collider_rid)
	var collider_node = instance_from_id(collider_id)
	
	if collider_node and collider_node.is_in_group("player"):
		queue_free()
		return
	if collider_node and collider_node.is_in_group("floor"):
		queue_free()
		return

	if collider_node and collider_node.is_in_group("dart"):
		return

	print("Groups:", collider_node.get_groups())
		
	var xf = state.get_transform()
	xf.origin = world_pos
	xf = xf.looking_at(world_pos + world_normal, Vector3.UP)
	xf.basis = xf.basis.rotated(Vector3.UP, PI)
	state.set_transform(xf)
	if collider_node:
		call_deferred("reparent_to", collider_node)

	print("Hit:", collider_node)
		
func reparent_to(new_parent):
	var old_transform = global_transform
	get_parent().remove_child(self)
	new_parent.add_child(self)
	global_transform = old_transform


func _on_body_entered(body):
	if body.is_in_group("dart"):
		return

	if body.is_in_group("player"):
		queue_free()
		return

	if body.is_in_group("floor"):
		queue_free()
		return
		
	if body.is_in_group("hitbox"):
		body.take_damage(damage)
		queue_free()
