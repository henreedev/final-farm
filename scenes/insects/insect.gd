extends CharacterBody2D
class_name Insect

#region: Globals
enum Type {FLY}

const MOVEMENT_REFRESH_DUR_MIN = 0.5
const MOVEMENT_REFRESH_DUR_MAX = 1.2
const MOVEMENT_DEVIATION_MAX = 20.0 # degrees
const BASE_SPEED = 20.0

var type : Type = Type.FLY
var health : int
var damage : int
var attack_cooldown : float # aka fire rate
var attack_range : int
var detection_range : int
var speed_mod : float

var target_dir : Vector2
var movement_dir : Vector2
var movement_speed : float
var target_options : Array[Plant] = []
var target : Plant
var attacking = false
var going_right = false
var going_down = false
 
@onready var movement_timer : Timer = $MovementTimer
@onready var attack_timer : Timer = $AttackTimer
@onready var detection_area : Area2D = $DetectionArea
@onready var detection_shape : CollisionShape2D = $DetectionArea/CollisionShape2D
@onready var attack_area : Area2D = $AttackArea
@onready var attack_shape : CollisionShape2D = $AttackArea/CollisionShape2D
@onready var asprite : AnimatedSprite2D = $AnimatedSprite2D
#endregion: Globals

#region: Universal functions
# Called when the node enters the scene tree for the first time.
func _ready():
	pick_values_on_type()
	retarget()

func pick_values_on_type():
	match type:
		Type.FLY:
			asprite.animation = "fly_front"
			health = 10
			damage = 10
			attack_cooldown = 1.0
			attack_range = 0
			detection_range = 8
			_set_range_area_radii()
	asprite.play()

func _set_range_area_radii():
	detection_shape.shape.radius = 8 + 16 * detection_range
	attack_shape.shape.radius = 8 + 16 * attack_range

func retarget():
	attacking = false
	var food_supply : Plant
	var production_plants : Array[Plant] = []
	var other_plants := {}
	for target_option in target_options:
		match target_option.type:
			Plant.Type.FOOD_SUPPLY:
				food_supply = target_option
			Plant.Type.EGGPLANT: # TODO add orange to be targeted first
				production_plants.append(target_option)
			_:
				var dist = position.distance_squared_to(target_option.position)
				other_plants[target_option] = dist

	# Below defines type-specific targeting behavior
	match type:
		Type.FLY:
			if not production_plants.is_empty():
				target = production_plants[0]
			else:
				if len(other_plants) > 0:
					var distances = other_plants.values()
					distances.sort()
					print(distances)
					target = other_plants.find_key(distances[0])

	if target:
		recalc_movement_vars()
		await target.died
		target = null
		get_new_target_options()
		retarget()
	else:
		recalc_movement_vars()
		await movement_timer.timeout
		retarget()

func get_new_target_options():
	target_options.clear()
	for area in detection_area.get_overlapping_areas():
		var parent = area.get_parent()
		if parent is Plant:
			if not parent.is_dead: 
				target_options.append(area.get_parent())

func _physics_process(delta):
	position += movement_speed * movement_dir * delta
	pick_animation()

func pick_animation():
	asprite.flip_h = going_right
	match type:
		Type.FLY:
			if not attacking:
				asprite.animation = "fly_front" if going_down else "fly_back"
	asprite.play()

func recalc_movement_vars():
	if attacking: movement_speed = 0.0
	else:
		if target:
			target_dir = position.direction_to(target.position)
		else:
			target_dir = -position.normalized() # go towards center map
		var deviation = deg_to_rad(randf_range(-MOVEMENT_DEVIATION_MAX, MOVEMENT_DEVIATION_MAX))
		movement_dir = Vector2.from_angle(target_dir.angle() + deviation)
		movement_speed = BASE_SPEED * lerpf(1, 0.5, abs(movement_dir.y)) # go half speed when going vertical (isometric)
	
	# Calculate variables to choose animations with
	going_right = movement_dir.x >= 0 
	going_down = movement_dir.y >= 0 

func _attack():
	attacking = true
	recalc_movement_vars()
	target.take_damage(damage)
	match type:
		Type.FLY:
			asprite.animation = "fly_attack_front" if going_down else "fly_attack_back"
			asprite.frame = 0
			asprite.play()
	await _do_attack_cooldown()
	if attacking:
		_attack()
	

func _do_attack_cooldown():
	attack_timer.start(attack_cooldown)
	await attack_timer.timeout

#endregion: Universal functions

#region: Connection functions
func _on_movement_timer_timeout():
	recalc_movement_vars()
	movement_timer.wait_time = randf_range(MOVEMENT_REFRESH_DUR_MIN, MOVEMENT_REFRESH_DUR_MAX)
	movement_timer.start()


func _on_detection_area_area_entered(area):
	var parent = area.get_parent()
	if parent is Plant:
		if not parent.is_dead: 
			target_options.append(area.get_parent())


func _on_detection_area_area_exited(area):
	var parent = area.get_parent()
	if parent is Plant:
		target_options.erase(area.get_parent())


func _on_attack_area_area_entered(area):
	if area.get_parent() == target:
		_attack()


func _on_animated_sprite_2d_animation_finished():
	match asprite.animation:
		"fly_attack_front": 
			asprite.animation = "fly_front" 
			asprite.play()
		"fly_attack_back":
			asprite.animation = "fly_back"
			asprite.play()
