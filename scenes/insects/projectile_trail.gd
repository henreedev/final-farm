extends Line2D
class_name ProjectileTrail

var parent : Node2D
var relative_to : Node2D
@export var duration := 2.0
var deleting := false
@export var use_global_transform := false
@export var use_relative_transform := false
# Called when the node enters the scene tree for the first time.
func _ready():
	clear_points()
	create_tween().tween_property(self, "deleting", true, 0).set_delay(duration)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if deleting:
		if len(points) <= 0:
			queue_free()
		else:
			remove_point(0)
	if parent and is_instance_valid(parent):
		if use_global_transform:
			add_point(parent.global_position)
		elif use_relative_transform:
			#print(-(relative_to.global_position - parent.global_position))
			#var rel_pos = relative_to.scale * (parent.global_position - relative_to.global_position)
			var rel_transform := parent.get_relative_transform_to_parent(relative_to)
			var rel_pos := rel_transform * relative_to.position 
			add_point(rel_pos)
		else:
			add_point(parent.position)
