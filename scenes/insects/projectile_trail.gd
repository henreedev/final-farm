extends Line2D
class_name ProjectileTrail

var parent : Projectile
var last_pos : Vector2
var duration := 2.0
var deleting := false

# Called when the node enters the scene tree for the first time.
func _ready():
	clear_points()
	create_tween().tween_property(self, "deleting", true, 0).set_delay(duration)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if deleting:
		if len(points) <= 0:
			queue_free()
		else:
			remove_point(0)
	if parent and is_instance_valid(parent):
		add_point(parent.position)
