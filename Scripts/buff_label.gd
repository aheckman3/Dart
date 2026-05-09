extends Control


var duration := 0.0
var buff_name := ""
var time_left := 0.0

func setup(buff_name_in: String, duration_seconds: float):
	buff_name = buff_name_in
	duration = duration_seconds
	time_left = duration
	$BuffName.text = buff_name


