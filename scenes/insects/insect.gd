extends CharacterBody2D
class_name Insect

#region: Globals
enum Type {FLY}

signal died 

const MOVEMENT_REFRESH_DUR_MIN = 0.5
const MOVEMENT_REFRESH_DUR_MAX = 1.2
const MOVEMENT_DEVIATION_MAX = 25.0 # degrees
const SPEED_DEVIATION = 0.05
const BASE_SPEED = 20.0

# Mutation tracking
static var fly_mutated := false 

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
var marked_by_player = false # TODO add red outline and target reticle when true
var is_dead = false
var speed_scale := 1.0
var paused := false


@onready var movement_timer : ScalableTimer = $MovementTimer
@onready var attack_timer : ScalableTimer = $AttackTimer
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
	movement_timer.start(1.0)

func pick_values_on_type():
	match type:
		Type.FLY:
			asprite.animation = "fly_front"
			health = 3
			damage = 25
			attack_cooldown = 1.0
			attack_range = 0
			detection_range = 8
			_set_range_area_radii()
	asprite.play()

func _set_range_area_radii():
	Utils.set_range_area_radii(detection_shape, detection_range)
	Utils.set_range_area_radii(attack_shape, attack_range)

func retarget():
	var food_supply := {}
	var production_plants := {}
	var other_plants := {}
	for target_option in target_options:
		var dist = position.distance_squared_to(target_option.position)
		match target_option.type:
			Plant.Type.FOOD_SUPPLY:
				food_supply[dist] = target_option
			Plant.Type.EGGPLANT: # TODO add orange to be targeted first
				production_plants[dist] = target_option
			_:
				other_plants[dist] = target_option

	# Below defines type-specific targeting behavior
	match type:
		Type.FLY:
			var all_plants = food_supply.merged(production_plants.merged(other_plants))
			if len(all_plants) > 0:
				var distances := all_plants.keys()
				distances.sort()
				target = all_plants[distances[0]]

	if target:
		if not _target_in_range():
			attacking = false
		recalc_movement_vars()
		await target.died
		target = null
		get_new_target_options()
		retarget()
	else:
		attacking = false
		recalc_movement_vars()
		await movement_timer.timeout
		retarget()

func _target_in_range():
	for area in attack_area.get_overlapping_areas():
		var parent = area.get_parent()
		if parent == target:
			return true
	return false

func get_new_target_options():
	target_options.clear()
	for area in detection_area.get_overlapping_areas():
		var parent = area.get_parent()
		if parent is Plant:
			if not parent.is_dead: 
				target_options.append(area.get_parent())

func _physics_process(delta):
	if paused:
		speed_scale = 0.0
	else:
		speed_scale = 1.0
	movement_timer.speed_scale = speed_scale
	attack_timer.speed_scale = speed_scale
	asprite.speed_scale = speed_scale
	delta *= speed_scale
	position += movement_speed * movement_dir * delta
	pick_animation()

func pick_animation():
	asprite.flip_h = going_right
	match type:
		Type.FLY:
			if not attacking and not (asprite.animation == "fly_attack_front" or asprite.animation == "fly_attack_back"):
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
		var speed_deviation = randf_range(1 - SPEED_DEVIATION, 1 + SPEED_DEVIATION)
		var speed_isometric_factor = lerpf(1, 0.5, abs(movement_dir.y))
		movement_speed = BASE_SPEED * speed_isometric_factor * speed_deviation
	
	# Calculate variables to choose animations with
	going_right = movement_dir.x >= 0 
	going_down = movement_dir.y >= 0 

func _attack(bypass : bool):
	if (not attacking) or bypass:
		attacking = true
		recalc_movement_vars()
		var current_target = target
		match type:
			Type.FLY:
				target.take_damage(damage)
				asprite.animation = "fly_attack_front" if going_down else "fly_attack_back"
				asprite.frame = 0
				asprite.play()
		await _do_attack_cooldown()
		if attacking and target:
			_attack(true)

func _do_attack_cooldown():
	attack_timer.start(attack_cooldown)
	await attack_timer.timeout

func take_damage(amount : int):
	health -= amount
	if health <= 0:
		die()

func die():
	is_dead = true
	died.emit()
	queue_free()

#endregion: Universal functions

#region: Connection functions
func _on_movement_timer_timeout():
	recalc_movement_vars()
	movement_timer.start(randf_range(MOVEMENT_REFRESH_DUR_MIN, MOVEMENT_REFRESH_DUR_MAX))


func _on_detection_area_area_entered(area):
	var parent = area.get_parent()
	if parent is Plant:
		if not parent.is_dead: 
			target_options.append(parent)


func _on_detection_area_area_exited(area):
	var parent = area.get_parent()
	if parent is Plant:
		target_options.erase(parent)


func _on_attack_area_area_entered(area):
	if area.get_parent() == target:
		if not attack_timer.is_stopped():
			await attack_timer.timeout
		if target:
			_attack(false)


func _on_animated_sprite_2d_animation_finished():
	match asprite.animation:
		"fly_attack_front": 
			asprite.animation = "fly_front" 
			asprite.play()
		"fly_attack_back":
			asprite.animation = "fly_back"
			asprite.play()
