extends Area3D

@export var float_speed: float = 0.8
@export var lifetime: float = 10.0
@export var wobble_amount: float = 0.8
@export var wobble_speed: float = 2.0

var time_alive := 0.0
var wobble_offset := randf() * 10


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

func pop():
	print("popped")
	queue_free()
