extends Node
class_name Utils

static var num_points = 50
static var arc_height = 50
static var better_zoom_shader = preload("res://scenes/map/better-zoom.gdshader")

static func upgrade(type : Plant.Type):
	match type:
		Plant.Type.EGGPLANT:
			Plant.eggplant_level += 1 as Plant.Level
		Plant.Type.BROCCOLI:
			Plant.broccoli_level += 1 as Plant.Level			

static func get_cost_of_next_upgrade(type : Plant.Type):
	match type:
		Plant.Type.EGGPLANT:
			match Plant.eggplant_level: # TODO
				Plant.Level.Level0:
					return 69
				Plant.Level.Level1:
					return 69 * 69
				Plant.Level.Level2: 
					return 69 * 3
		Plant.Type.BROCCOLI:
			match Plant.broccoli_level: # TODO
				Plant.Level.Level0:
					return 10
				Plant.Level.Level1:
					return 69 * 69
				Plant.Level.Level2: 
					return 69 * 3
	return -1

static func get_cost_of_type(type : Plant.Type): # TODO add all plants
	match type:
		Plant.Type.EGGPLANT:
			return 5
		Plant.Type.BROCCOLI:
			return 1

static func give_zoom_shader(node_with_mat : Node2D):
	node_with_mat.material = ShaderMaterial.new()
	node_with_mat.material.shader = better_zoom_shader

static func set_range_area_radii(shape : CollisionShape2D, tile_radius : int):
	shape.shape.radius = 8 + 16 * tile_radius

static func calc_arc_between(p1 : Vector2, p2 : Vector2):
	var points = []
	for i in range(num_points + 1):
		var t := float(i) / float(num_points)
		var x = lerp(p1.x, p2.x, t)
		var y = lerp(p1.y, p2.y, t) - arc_height * sin(PI * t)
		points.append(Vector2(x, y))
	return points

static func calc_point_on_arc_between(p1 : Vector2, p2 : Vector2, t : float):
	var x = lerp(p1.x, p2.x, t)
	var y = lerp(p1.y, p2.y, t) - arc_height * sin(PI * t)
	return Vector2(x, y)
	
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
