extends Sprite2D
class_name Hoe

var angle_cone = 45.0
var duration = 1.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var half = deg_to_rad(angle_cone / 2.0)
	var tween : Tween = create_tween()
	tween.tween_property(self, "rotation", rotation - half, duration).from(rotation + half)
	tween.tween_callback(queue_free)


func _on_hitbox_area_entered(area: Area2D) -> void:
	# if area is Plant: 
		# refresh sleep, maybe boost stats briefly
	# elif area is Insect:
		# hit it
	pass 
