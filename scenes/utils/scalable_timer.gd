extends Node
class_name ScalableTimer

signal timeout

var disabled := false
var time_left := 0.0
var stopped := true
var speed_scale := 1.0

func start(duration : float):
	time_left = duration
	stopped = false

func is_stopped():
	return stopped

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not (stopped or disabled):
		time_left -= delta * speed_scale
		if time_left < 0:
			stopped = true
			time_left = 0.0
			timeout.emit()
