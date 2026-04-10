extends RigidBody3D

@export var speed := 60
@export var lifetime := 15.0
var stuck := false
var direction: Vector3 = Vector3.ZERO

func _ready():
	if direction != Vector3.ZERO:
		linear_velocity = direction.normalized() * speed
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(_delta):
	if stuck:
		return

func _integrate_forces(state):
	if stuck:
		return
		
	if state.get_contact_count() > 0:
		stick_to_surface(state)


func stick_to_surface(state):
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	sleeping = true
	freeze = true
	
	var world_pos = state.get_contact_local_position(0)
	var world_normal = state.get_contact_local_normal(0)
	var collider_rid = state.get_contact_collider(0)
	
	var collider_id = PhysicsServer3D.body_get_object_instance_id(collider_rid)
	var collider_node = instance_from_id(collider_id)

	global_transform.origin = world_pos
	look_at(world_pos + world_normal, Vector3.UP)
	if collider_node:
		call_deferred("reparent_to", collider_node)
		
func reparent_to(new_parent):
	var old_transform = global_transform
	get_parent().remove_child(self)
	new_parent.add_child(self)
	global_transform = old_transform
	
