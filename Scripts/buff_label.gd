extends Control


var duration := 0.0
var buff_name := ""
var time_left := 0.0


func setup(name: String, duration_seconds: float):
	buff_name = name
	duration = duration_seconds
	time_left = duration
	$BuffName.text = name

func _process(delta: float) -> void:
	time_left -= delta
	
	$BuffTimer.text = "%0.1f" % time_left + "s"
	if time_left <= 0:
		queue_free()
