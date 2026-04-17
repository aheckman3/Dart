extends Control

@export var dot_size: float = 4.0
@export var dot_color: Color = Color.WHITE

func _ready():
	set_process(true)
	
func _process(_delta):
	queue_redraw()
	
func _draw():
	var center = size / 2
	draw_circle(center, dot_size, dot_color)
	
