extends Node
class_name Utils

static var num_points = 50
static var arc_height = 50

static func calc_arc_between(p1 : Vector2, p2 : Vector2):
	var points = []
	for i in range(num_points + 1):
		var t := float(i) / float(num_points)
		var x = lerp(p1.x, p2.x, t)
		var y = lerp(p1.y, p2.y, t) - arc_height * sin(PI * t)
		points.append(Vector2(x, y))
	return points

static func tween_arc_between(parent : Node2D, p1 : Vector2, p2 : Vector2, duration : float):
	var hoz_tween = parent.create_tween()
	var vert_tween = parent.create_tween()
	var half_dur = duration / 2.0
	
	var diff = p2 - p1
	var angle = (diff).angle()
	if angle < PI / 4 or (angle > PI * 0.75 and angle < PI):
		# Throwing horizontally, so y should have a smooth arc and x should be linear
		hoz_tween.tween_property(parent, "global_position:x", p2.x, duration).from(p1.x)
		vert_tween.tween_property(parent, "global_position:y", p2.y - arc_height, half_dur).from(p1.y).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		vert_tween.tween_property(parent, "global_position:y", p2.y, half_dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	else:
		# Throwing vertically, so opposite
		hoz_tween.tween_property(parent, "global_position:x", p2.x - diff.x / 2, half_dur).from(p1.x).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		hoz_tween.tween_property(parent, "global_position:x", p2.x, half_dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		vert_tween.tween_property(parent, "global_position:y", p2.y - arc_height, half_dur).from(p1.y).set_ease(Tween.EASE_OUT)
		vert_tween.tween_property(parent, "global_position:y", p2.y, half_dur).set_ease(Tween.EASE_IN)
		
	
	return hoz_tween
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
