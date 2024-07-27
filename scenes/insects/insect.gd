extends CharacterBody2D
class_name Insect

#region: Globals
enum Type {FLY, GRUB, MOTH, SNAIL, BEE, FUNGI, ANT, CATERPILLAR, SPORESPAWN,\
		 LOCUST, BEETLE, CRICKET, FIREFLY}

signal died 


const FIREFLY_BOT_PROJ_OFFSET = Vector2(-7, 11)
const FIREFLY_TOP_PROJ_OFFSET = Vector2(-7, 5)
const MOVEMENT_REFRESH_DUR_MIN = 0.5
const MOVEMENT_REFRESH_DUR_MAX = 1.2
const MOVEMENT_DEVIATION_MAX = 25.0 # degrees
const SPEED_DEVIATION = 0.05

var type : Type 
var health : int
var damage : int
var attack_cooldown : float # aka fire rate
var attack_range : int
var detection_range : int
var base_speed : float

var target_dir : Vector2
var movement_dir : Vector2
var movement_speed : float
var movement_vec : Vector2 
var target_options : Array[Plant] = []
var target : Plant
var attacking = false
var going_right = false
var going_down = false
var marked_by_player = false # TODO add red outline and target reticle when true
var is_dead = false
var speed_scale := 1.0
var paused := false
var moves_straight := false
var fires_projectile := false
var anim_str : String
var deletes_after_firing := false

var projectile_scene : PackedScene = preload("res://scenes/plants/projectile.tscn")
var projectile_radius : int
var projectile_speed : float
var projectile_lifespan : float

var label_setting : LabelSettings = preload("res://scenes/UI/bag_icon.tres")
@onready var movement_timer : ScalableTimer = $MovementTimer
@onready var attack_timer : ScalableTimer = $AttackTimer
@onready var detection_area : Area2D = $DetectionArea
@onready var detection_shape : CollisionShape2D = $DetectionArea/CollisionShape2D
@onready var attack_area : Area2D = $AttackArea
@onready var attack_shape : CollisionShape2D = $AttackArea/CollisionShape2D
@onready var asprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var player : Player = get_tree().get_first_node_in_group("player")
@onready var main : Main = get_tree().get_first_node_in_group("main")
@onready var health_bar_label : Label = $HealthBar/Label
@onready var health_bar = $HealthBar
@onready var bug_hit_sound : AudioStreamPlayer2D = $BugHit
@onready var flying_sound : AudioStreamPlayer2D = $FlyingSound
#endregion: Globals

#region: Universal functions
# Called when the node enters the scene tree for the first time.
func _ready():
	main.info_toggled.connect(update_health_bar)
	Utils.give_zoom_shader(self)
	pick_values_on_type()
	retarget()
	movement_timer.start(1.0)
	setup_health_bar()

func setup_health_bar():
	health_bar_label.label_settings = LabelSettings.new()
	health_bar_label.label_settings.font = label_setting.font
	health_bar_label.label_settings.font_color = Color(1, 0.2, 0.2, 1)
	health_bar_label.label_settings.font_size = label_setting.font_size
	health_bar_label.label_settings.shadow_color = label_setting.shadow_color
	health_bar_label.label_settings.shadow_size = label_setting.shadow_size
	update_health_bar()

func pick_values_on_type():
	health = Utils.get_insect_health(type)
	damage = Utils.get_insect_damage(type)
	attack_cooldown = Utils.get_insect_attack_cooldown(type)
	attack_range = Utils.get_insect_range(type)
	base_speed = Utils.get_insect_speed(type)
	anim_str = Utils.get_insect_string(type) + "_"
	asprite.animation = anim_str + "front"
	detection_range = Utils.get_insect_detection_range(type)
	match type:
		Type.FLY:
			flying_sound.play()
		Type.MOTH:
			fires_projectile = true
			flying_sound.play()
			projectile_radius = 3
			projectile_lifespan = 1.0
			projectile_speed = 60.0
		Type.GRUB:
			asprite.offset = Vector2(0, 0)
		Type.SNAIL:
			asprite.offset = Vector2(0, 0)
			moves_straight = true
		Type.FUNGI:
			fires_projectile = true
			deletes_after_firing = true
			asprite.offset = Vector2(0, 0)
		Type.FIREFLY:
			fires_projectile = true
			projectile_radius = 3
			projectile_lifespan = 2.0
			projectile_speed = 300.0
		Type.SPORESPAWN:
			fires_projectile = true
			projectile_radius = 3
			projectile_lifespan = 5.0
		Type.BEETLE:
			asprite.offset = Vector2(0, 0)
			moves_straight = true

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
		Type.FLY, Type.GRUB, Type.MOTH, Type.FUNGI, Type.ANT, Type.LOCUST, \
		Type.CRICKET, Type.SPORESPAWN, Type.FIREFLY:
			var all_plants = food_supply.merged(production_plants.merged(other_plants))
			if len(all_plants) > 0:
				var distances := all_plants.keys()
				distances.sort()
				target = all_plants[distances[0]]
		Type.BEE, Type.BEETLE:
			if len(production_plants) > 0:
				var distances = production_plants.keys()
				distances.sort()
				target = production_plants[distances[0]]
			elif len(food_supply) > 0:
				target = food_supply.values()[0]
		Type.SNAIL, Type.CATERPILLAR:
			if len(food_supply) > 0:
				target = food_supply.values()[0]

	if target and is_instance_valid(target):
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

func update_health_bar():
	health_bar_label.text = str(health)
	if main.show_info:
		health_bar.show()
	else:
		health_bar.hide()


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
	position += movement_vec * delta * speed_scale

func pick_animation():
	asprite.flip_h = going_right
	if not (attacking):
		if not (asprite.animation == anim_str + "attack_front" or asprite.animation == anim_str + "attack_back"):
			asprite.animation = anim_str + "front" if going_down else anim_str + "back"
		asprite.play()

func recalc_movement_vars():
	if attacking: movement_speed = 0.0
	else:
		if target and is_instance_valid(target):
			target_dir = position.direction_to(target.position)
		else:
			target_dir = -position.normalized() # go towards center map
		var deviation = deg_to_rad(randf_range(-MOVEMENT_DEVIATION_MAX, MOVEMENT_DEVIATION_MAX))
		if moves_straight: deviation = 0
		movement_dir = Vector2.from_angle(target_dir.angle() + deviation)
		var speed_deviation = randf_range(1 - SPEED_DEVIATION, 1 + SPEED_DEVIATION)
		var speed_isometric_factor = lerpf(1, 0.5, abs(movement_dir.y))
		movement_speed = base_speed * speed_isometric_factor * speed_deviation
		movement_vec = movement_dir * movement_speed
	# Calculate variables to choose animations with
	going_right = movement_dir.x >= 0 
	going_down = movement_dir.y >= 0 

func _attack(bypass : bool):
	if (not attacking) or bypass:
		attacking = true
		recalc_movement_vars()
		var current_target = target
		if fires_projectile:
			_fire_projectile()
		else:
			target.take_damage(damage)
			bug_hit_sound.play()
		asprite.animation = anim_str + "attack_front" if going_down else anim_str + "attack_back"
		asprite.frame = 0
		asprite.play()
		await _do_attack_cooldown()
		if attacking and target and is_instance_valid(target):
			_attack(true)

func _fire_projectile():
	var projectile : Projectile = projectile_scene.instantiate()
	projectile.insect_type = type
	projectile.allied = false
	projectile.damage = damage
	projectile.radius = projectile_radius
	projectile.speed = projectile_speed
	projectile.dir = target_dir
	projectile.rotation = target_dir.angle()
	projectile.position = position 
	if type == Type.FIREFLY:
		var offset_base = FIREFLY_BOT_PROJ_OFFSET if going_down else FIREFLY_TOP_PROJ_OFFSET
		var projectile_offset = Vector2(offset_base.x * -1 if going_right else 1.0 - 1,\
				offset_base.y + asprite.offset.y) 
		projectile.position += projectile_offset
	projectile.should_fire = true
	projectile.target = target
	main.add_child.call_deferred(projectile)
	if deletes_after_firing: die()

func _do_attack_cooldown():
	attack_timer.start(attack_cooldown)
	await attack_timer.timeout

func take_damage(amount : int):
	health -= amount
	update_health_bar()
	if health <= 0:
		die()

func die():
	is_dead = true
	player.adjust_bug_kills(Utils.get_insect_kill_reward(type))
	main.on_insect_died()
	died.emit()
	queue_free()

#endregion: Universal functions

#region: Connection functions
func _on_movement_timer_timeout():
	recalc_movement_vars()
	pick_animation()
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
		if target and is_instance_valid(target):
			_attack(false)


func _on_animated_sprite_2d_animation_finished():
	var attack_str_front = anim_str + "attack_front"
	var attack_str_back = anim_str + "attack_back"
	match asprite.animation:
		attack_str_front:
			asprite.animation = anim_str + "front" 
			asprite.play()
		attack_str_back:
			asprite.animation = anim_str + "back"
			asprite.play()
