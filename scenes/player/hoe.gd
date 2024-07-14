extends Sprite2D
class_name Hoe

var angle_cone = 45.0
var duration = 1.0
var final_scale = 1.0
const SPAWN_DURATION_RATIO = 0.5 # what ratio of the total duration is taken up by spawning and despawning? 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var actual_duration = duration * (1 - SPAWN_DURATION_RATIO)
	var final_scale_vec = Vector2(final_scale, final_scale)
	var half_spawn_dur = duration * SPAWN_DURATION_RATIO / 2.0
	var half = deg_to_rad(angle_cone / 2.0)
	var start_rot = rotation + half
	var end_rot = rotation - half
	rotation = start_rot
	scale = Vector2(0, 0)
	var rot_tween : Tween = create_tween()
	var scale_tween : Tween = create_tween()
	scale_tween.tween_property(self, "scale", final_scale_vec, half_spawn_dur).set_trans(Tween.TRANS_CIRC)
	scale_tween.tween_interval(actual_duration)
	scale_tween.tween_property(self, "scale", Vector2(0,0), half_spawn_dur).set_trans(Tween.TRANS_CIRC)
	rot_tween.tween_property(self, "rotation", end_rot, duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	rot_tween.tween_callback(queue_free)


func _on_hitbox_area_entered(area: Area2D) -> void:
	# if area is Plant: 
		# refresh sleep, maybe boost stats briefly
	# elif area is Insect:
		# hit it
	pass 
