extends AnimatedSprite2D
class_name Hoe

var hoe_line_scene : PackedScene = preload("res://scenes/player/hoe_line.tscn")

var ccw = true

var angle_cone : float
var duration : float
var buff_duration : float
var buff_start_strength : float
var buff_end_strength : float
var final_scale : float
@onready var particles = $Node/Particles
@onready var delete_timer : Timer = $DeleteTimer
@onready var player : Player = get_tree().get_first_node_in_group("player")
@onready var line_root = $LineRoot

const SPAWN_DURATION_RATIO = 0.5 # what ratio of the total duration is taken up by spawning and despawning? 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	animation = "normal" if ccw else "flipped"
	play()
	$Hitbox.scale.y = 1 if ccw else -1
	
	var actual_duration = duration * (1 - SPAWN_DURATION_RATIO)
	var half_spawn_dur = duration * SPAWN_DURATION_RATIO / 2.0
	var final_scale_vec = Vector2(final_scale, final_scale)
	
	var scale_tween : Tween = create_tween()
	scale_tween.tween_property(self, "scale", final_scale_vec, half_spawn_dur).set_trans(Tween.TRANS_CIRC)
	scale_tween.tween_callback(add_hoe_line)
	scale_tween.tween_interval(actual_duration)
	scale_tween.tween_callback(line_root.queue_free)
	scale_tween.tween_property(self, "scale", Vector2(0,0), half_spawn_dur).set_trans(Tween.TRANS_CIRC)
	
	var rot_tween : Tween = create_tween()
	var half = deg_to_rad(angle_cone / 2.0)
	var start_rot = rotation + half
	var end_rot = rotation - half 
	rotation = start_rot if ccw else end_rot
	if ccw:
		rot_tween.tween_property(self, "rotation", end_rot, duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	else:
		rot_tween.tween_property(self, "rotation", start_rot, duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	rot_tween.tween_callback(delete)
	

func add_hoe_line():
	var hoe_line : ProjectileTrail = hoe_line_scene.instantiate()
	hoe_line.parent = line_root
	hoe_line.relative_to = self
	add_child(hoe_line)

func _on_hitbox_area_entered(area) -> void:
	var parent = area.get_parent()
	if parent is Plant: 
		parent.on_hit_by_hoe(buff_duration, buff_start_strength, buff_end_strength)

func delete():
	delete_timer.start(0.5)
	create_tween().tween_property(particles, "modulate:a", 0, 0.5).set_trans(Tween.TRANS_CUBIC)
	await delete_timer.timeout
	queue_free()
