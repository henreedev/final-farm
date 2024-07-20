extends Node
class_name Utils

static var num_points = 50
static var arc_height = 50
static var better_zoom_shader = preload("res://scenes/map/better-zoom.gdshader")


static var eggplant_level : Plant.Level = Plant.Level.Level0
static var broccoli_level : Plant.Level = Plant.Level.Level0


static func upgrade(type : Plant.Type):
	match type:
		Plant.Type.EGGPLANT:
			eggplant_level += 1 as Plant.Level
		Plant.Type.BROCCOLI:
			broccoli_level += 1 as Plant.Level			

static func get_plant_damage(type : Plant.Type):
	match type:
		Plant.Type.EGGPLANT:
			return 0
		Plant.Type.BROCCOLI:
			match broccoli_level: # TODO
				Plant.Level.Level0:
					return 1
				Plant.Level.Level1:
					return 2
				Plant.Level.Level2: 
					return 3
				Plant.Level.Level3: 
					return 4
		_: 
			return -1

static func get_plant_health(type : Plant.Type):
	match type:
		Plant.Type.FOOD_SUPPLY:
			return 1000
		Plant.Type.EGGPLANT:
			match eggplant_level: # TODO
				Plant.Level.Level0:
					return 100
				Plant.Level.Level1:
					return 200
				Plant.Level.Level2: 
					return 300
				Plant.Level.Level3: 
					return 500
		Plant.Type.BROCCOLI:
			match broccoli_level: # TODO
				Plant.Level.Level0:
					return 100
				Plant.Level.Level1:
					return 125
				Plant.Level.Level2: 
					return 150
				Plant.Level.Level3: 
					return 200
	return -1

static func get_plant_range(type : Plant.Type):
	match type:
		Plant.Type.EGGPLANT:
			return 0
		Plant.Type.BROCCOLI:
			match broccoli_level: # TODO
				Plant.Level.Level0:
					return 3
				Plant.Level.Level1:
					return 3
				Plant.Level.Level2: 
					return 4
				Plant.Level.Level3: 
					return 4
	return -1

static func get_plant_attack_cooldown(type : Plant.Type):
	match type:
		Plant.Type.EGGPLANT:
			match eggplant_level: # TODO
				Plant.Level.Level0:
					return 10.0
				Plant.Level.Level1:
					return 10.0
				Plant.Level.Level2: 
					return 10.0
				Plant.Level.Level3: 
					return 10.0
		Plant.Type.BROCCOLI:
			match broccoli_level: # TODO
				Plant.Level.Level0:
					return 1.0
				Plant.Level.Level1:
					return 1.0
				Plant.Level.Level2: 
					return 0.9
				Plant.Level.Level3: 
					return 0.8
	return -1.0

static func get_plant_spawn_duration(type : Plant.Type):
	match type:
		Plant.Type.EGGPLANT:
			return 10
		Plant.Type.BROCCOLI:
			return 1
		_:
			return -1

static func get_next_upgrade_cost(type : Plant.Type):
	match type:
		Plant.Type.EGGPLANT:
			match eggplant_level: # TODO
				Plant.Level.Level0:
					return 69
				Plant.Level.Level1:
					return 69 * 69
				Plant.Level.Level2: 
					return 69 * 3
		Plant.Type.BROCCOLI:
			match broccoli_level: # TODO
				Plant.Level.Level0:
					return 10
				Plant.Level.Level1:
					return 69 * 69
				Plant.Level.Level2: 
					return 69 * 3
	return -1

static func get_plant_cost(type : Plant.Type): # TODO add all plants
	match type:
		Plant.Type.EGGPLANT:
			return 5
		Plant.Type.BROCCOLI:
			return 1
	return -1

static func get_plant_blurb(type : Plant.Type):
	match type:
		Plant.Type.EGGPLANT:
			return "BLURB NOT ADDED YET"
		Plant.Type.BROCCOLI:
			return "BLURB NOT ADDED YET"
		_:
			return "-1"

static func get_plant_upgrade_blurb(type : Plant.Type, level : Plant.Level):
	match type: 
		Plant.Type.EGGPLANT:
			match level: # TODO
				Plant.Level.Level1:
					return "Level 1 upgrade blurb not added yet"
				Plant.Level.Level2: 
					return "Level 2 upgrade blurb not added yet"
				Plant.Level.Level3: 
					return "Level 3 upgrade blurb not added yet"
		Plant.Type.BROCCOLI:
			match level: # TODO
				Plant.Level.Level1:
					return "Level 1 upgrade blurb not added yet"
				Plant.Level.Level2: 
					return "Level 2 upgrade blurb not added yet"
				Plant.Level.Level3: 
					return "Level 3 upgrade blurb not added yet"
		_:
			return "-1"
static func get_plant_special_blurb(type : Plant.Type):
	match type: 
		Plant.Type.EGGPLANT, Plant.Type.BROCCOLI:
			return "Special Stat: N/A"
		_:
			return "-1"

static func get_plant_special_value(type : Plant.Type):
	match type: 
		Plant.Type.EGGPLANT, Plant.Type.BROCCOLI:
			return ""
		_:
			return "-1"

static func get_plant_level(type : Plant.Type):
	match type:
		Plant.Type.EGGPLANT:
			return eggplant_level
		Plant.Type.BROCCOLI:
			return broccoli_level
		_: 
			return -1

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
