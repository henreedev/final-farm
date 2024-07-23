extends AnimatedSprite2D
class_name Plant

#region: Global vars
enum Type {EGGPLANT, BROCCOLI, TOMATO, POTATO, CELERY, \
		   CORN, WATERMELON, PEPPER, BANANA, LEMONLIME, WILLOW, WILLOW_ARM, FOOD_SUPPLY}
enum Level {Level0, Level1, Level2, Level3}


const PROJECTILE_OFFSET = Vector2(-4, 2)

signal fire_condition_met
signal died
signal fired(projectile : Projectile)

var type : Type 

var health : int
var health_drain_percent : float
var time_to_grow : int
var damage : int
var attack_range : int
var projectile_radius : float
var projectile_speed : float 
var projectile_lifespan : float
var health_decay : int
var attack_cooldown : float
var upgrade_fire_rate_mod := 1.0
var hoe_fire_rate_mod := 1.0
var is_sleeping := false
var cant_sleep := false
var is_dead := false
#endregion: Global vars

#region: Eggplant vars
signal eggplant_arrived
var eggplant_scene : PackedScene = preload("res://scenes/plants/eggplant.tscn")
var eggplant_spawn_pos = Vector2(12, -13)
var eggplant_spawn_angle = -PI / 4.0
#endregion: Eggplant vars

#region: Pepper vars
var fired_projectile : Projectile
#endregion: Pepper vars


#region: Other vars
var plant_scene : PackedScene = preload("res://scenes/plants/plant.tscn")
var projectile_scene : PackedScene = preload("res://scenes/plants/projectile.tscn")
var hoe_tween : Tween
var target : Insect
var target_options : Array[Insect] = []
var attack_dir : Vector2
var attacking := false
var growing := true
var sleeping := false
var paused := false
var can_cancel_atk_anim := true
var anims_bidir := true
var can_attack := true
var fires_projectile := true
var fires_after_condition := false
var deletes_after_firing := false
var facing_right := randf() > 0.5
var facing_down := true
var anim_str : String
var health_to_decay : float = 0
var health_decay_mod : float = 1.0
var display_health := true
#endregion: Other vars

#region: Willow vars
var willow_num_arms : int
var willow_arm_root_index : int
var willow_arm_index : int
const willow_outline_color := Color(0.2, 0.4, 0.2, 1.0) 
#endregion: Willow vars

@onready var attack_timer : ScalableTimer = $AttackTimer
@onready var main : Main = get_tree().get_first_node_in_group("main")
@onready var floor : TileMapLayer = get_tree().get_first_node_in_group("floor")
@onready var health_bar = $HealthBar
@onready var health_bar_label = $HealthBar/Label
@onready var sleep_timer : ScalableTimer = $SleepTimer
@onready var sleep_effect : AnimatedSprite2D = $SleepEffect
@onready var normal_hit : AudioStreamPlayer2D = $normal
@onready var small_hit : AudioStreamPlayer2D = $small
@onready var tomato_hit : AudioStreamPlayer2D = $tomato
@onready var celery_hit : AudioStreamPlayer2D = $celery
@onready var attack_area : Area2D = $AttackArea
@onready var hurtbox : Area2D = $Hurtbox
var sleep_time = 15.0
#region: Universal functions
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main.info_toggled.connect(update_health_bar)
	Utils.give_zoom_shader(self)
	pick_stats()
	pick_starting_animation()

func pick_stats():
	var _type = type if not type == Type.WILLOW_ARM else Type.WILLOW
	damage = Utils.get_plant_damage(_type)
	health = Utils.get_plant_health(_type)
	attack_range = Utils.get_plant_range(_type)
	attack_cooldown = Utils.get_plant_attack_cooldown(_type)
	health_decay = Utils.get_plant_health_decay(_type) * 0.01 * health
	upgrade_fire_rate_mod = Utils.get_plant_attack_cooldown(_type, Level.Level0) / Utils.get_plant_attack_cooldown(_type)
	anim_str = Utils.get_plant_string(_type) + "_"
	match type:
		Type.FOOD_SUPPLY:
			can_attack = false
			health_bar.scale = Vector2(2, 2)
			health_bar.position = Vector2(0, 8)
		Type.EGGPLANT:
			flip_h = facing_right
			anims_bidir = false
			can_attack = false
		Type.BROCCOLI:
			projectile_lifespan = 0.7
			projectile_radius = 3
			projectile_speed = 120.0
		Type.CORN:
			anims_bidir = false
			projectile_lifespan = 0.5
			projectile_radius = 3
			projectile_speed = 200.0
		Type.LEMONLIME:
			projectile_lifespan = 1.5
			projectile_radius = 6
			projectile_speed = 180.0
		Type.BANANA:
			can_cancel_atk_anim = false
			projectile_lifespan = 10
			projectile_radius = 9
			projectile_speed = 500.0
		Type.POTATO:
			offset = Vector2(0, -8)
			anims_bidir = false
			deletes_after_firing = true
			fires_after_condition = true
		Type.PEPPER:
			anims_bidir = false
			can_cancel_atk_anim = false
		Type.CELERY:
			fires_projectile = false
		Type.WATERMELON:
			can_cancel_atk_anim = false
		Type.WILLOW:
			anims_bidir = false
			scale = Utils.get_plant_scale(_type)
			attack_area.process_mode = Node.PROCESS_MODE_DISABLED
			willow_num_arms = Utils.get_plant_special_value(_type)
		Type.WILLOW_ARM:
			z_index = 0
			willow_arm_index = willow_arm_root_index
			growing = false
			anims_bidir = false
			hurtbox.process_mode = Node.PROCESS_MODE_DISABLED
			display_health = false
			fires_projectile = false
			sleep_timer.disabled = true
			material.set_shader_parameter("outline_active", true)
			material.set_shader_parameter("outline_color", willow_outline_color)
			
	Utils.set_range_area_radii($AttackArea/CollisionShape2D, attack_range)
	update_health_bar()

func _do_attack_cooldown():
	attack_timer.start(attack_cooldown)
	await attack_timer.timeout

func pick_starting_animation():
	if type == Type.WILLOW_ARM: 
		pick_animation()
	else:
		animation = anim_str + "grow"
		sprite_frames.set_animation_speed(animation, sprite_frames.get_frame_count(animation) / float(Utils.get_plant_spawn_duration(type)))
	play()

func on_hit_by_hoe(duration, start_strength, end_strength):
	if type == Type.WILLOW:
		for child in get_children():
			if child is Plant:
				child.on_hit_by_hoe(duration, start_strength, end_strength)
	sleeping = false
	sleep_effect.hide()
	sleep_timer.start(sleep_time)
	var start_modulate = Color(start_strength, start_strength, start_strength, 1)
	var end_modulate = Color(end_strength, end_strength, end_strength, 1)
	health_decay_mod = 0.0
	if hoe_tween:
		hoe_tween.kill()
	hoe_tween = create_tween()
	hoe_tween.tween_property(self, "hoe_fire_rate_mod", end_strength, duration)\
		.from(start_strength)\
		.set_trans(Tween.TRANS_LINEAR)
	hoe_tween.parallel().tween_property(self, "modulate", end_modulate, duration)\
		.from(start_modulate)\
		.set_trans(Tween.TRANS_LINEAR)
	hoe_tween.tween_property(self, "hoe_fire_rate_mod", 1.0, 0)
	hoe_tween.tween_property(self, "health_decay_mod", 1.0, 0)
	hoe_tween.tween_property(self, "modulate", Color(1,1,1,1), 0.5).set_trans(Tween.TRANS_CUBIC)
	retarget()

func _physics_process(delta) -> void:
	if paused or sleeping:
		speed_scale = 0
	elif is_dead:
		speed_scale = 1
	else:
		speed_scale = hoe_fire_rate_mod * (upgrade_fire_rate_mod if not growing else 1.0) 
	sleep_timer.speed_scale = speed_scale  * health_decay_mod
	attack_timer.speed_scale = speed_scale
	calc_facing_vars()
	pick_animation()
	_decay_health(delta)

func _decay_health(delta : float):
	health_to_decay += delta * health_decay * speed_scale * health_decay_mod
	if growing: health_to_decay = 0.0
	var int_health_to_decay = int(health_to_decay)
	if int_health_to_decay > 0:
		health_to_decay -= int_health_to_decay
		take_damage(int_health_to_decay)
	

func _attack(bypass : bool):
	if not can_attack or sleeping:
		pick_animation()
	else:
		if target and ((not attacking) or bypass):
			attacking = true
			if not can_cancel_atk_anim:
					if (animation == anim_str + "shoot_front" or \
						animation == anim_str + "shoot_back" or \
						animation == anim_str + "shoot"):
						await animation_finished
			calc_facing_vars()
			var current_target = target
			if anims_bidir:
				animation = anim_str + "shoot_front" if facing_down else anim_str + "shoot_back"
			else:
				willow_arm_index = _angle_to_index(attack_dir.angle())
				animation = anim_str + "shoot" + _get_willow_arm_string()
			set_frame_and_progress(0, 0) 
			play()
			if fires_projectile:
				if fires_after_condition:
					await fire_condition_met
				fire_projectile()
			else:
				celery_hit.play()
				target.take_damage(damage)
			sleep_timer.start(sleep_time)
			await _do_attack_cooldown()
			if attacking and target:
				_attack(true)

func retarget():
	var target_dists := {}
	if len(target_options) > 0:
		for target_option in target_options:
			if target_option and not target_option.is_dead: 
				var dist = position.distance_squared_to(target_option.position)
				target_dists[dist] = target_option
		if len(target_dists) > 0:
			var distances := target_dists.keys()
			distances.sort()
			target = target_dists[distances[0]]
	else:
		target = null
		attacking = false
	
	if target and is_instance_valid(target):
		var current_target = target
		await target.died
		if current_target == target:
			target_options.erase(target)
			target = null
			retarget()
	else:
		attacking = false

func fire_projectile():
	match type:
		Type.CORN:
			small_hit.play()
		Type.TOMATO:
			tomato_hit.play()
		_:
			normal_hit.play()
	var projectile : Projectile = projectile_scene.instantiate()
	projectile.type = type
	projectile.allied = true
	projectile.damage = damage
	projectile.radius = projectile_radius
	projectile.speed = projectile_speed
	projectile.dir = attack_dir
	projectile.rotation = attack_dir.angle()
	var projectile_offset = Vector2(PROJECTILE_OFFSET.x * -1 if facing_right else 1.0,\
				PROJECTILE_OFFSET.y * -1 if facing_down else 1.0) 
	projectile.position = position + projectile_offset
	projectile.lifespan = projectile_lifespan
	projectile.should_fire = true
	projectile.target = target
	main.add_child.call_deferred(projectile)
	fired_projectile = projectile
	if deletes_after_firing:
		queue_free()


func pick_animation():
	flip_h = facing_right if anims_bidir else false
	if not (attacking or growing):
		if anims_bidir:
			if not (animation == anim_str + "shoot_front" or animation == anim_str + "shoot_back"):
				animation = anim_str + "idle_front" if facing_down else anim_str + "idle_back"
		else:
			if not (animation == anim_str + "shoot" + _get_willow_arm_string()):
				animation = anim_str + "idle" + _get_willow_arm_string() 
				_set_willow_arm_offset()
		play()

func calc_facing_vars():
	if target:
		attack_dir = position.direction_to(target.position) # FIXME could be expensive
		facing_right = attack_dir.x >= 0.0
		facing_down = attack_dir.y >= 0.0 

func _get_willow_arm_string():
	if type == Type.WILLOW_ARM:
		return "_arm" + str(willow_arm_index)
	else: return ""

func take_damage(amount : int):
	health -= amount
	update_health_bar()
	if health <= 0:
		die()

func update_health_bar():
	health_bar_label.text = str(health)
	if main.show_info and display_health:
		health_bar.show()
	else:
		health_bar.hide()

func die():
	is_dead = true
	died.emit()
	if hoe_tween:
		hoe_tween.kill()
	modulate = Color(1,1,1,1)
	
	var coords = floor.local_to_map(global_position)
	if coords: 
		var tile = floor.get_cell_tile_data(coords)
		if tile: 
			floor.set_cell(coords, 0, Vector2i(0, 0))
	queue_free()
#endregion: Universal functions

#region: Willow functions
func move_towards_root_anim():
	willow_arm_index = move_toward(willow_arm_index, willow_arm_root_index, 1)

func _set_willow_arm_offset():
	if type == Type.WILLOW_ARM:
		var arm_offset : Vector2
		match willow_arm_index:
			0:
				arm_offset = Vector2(2, -1)
			1:
				arm_offset = Vector2(1, -2)
			2:
				arm_offset = Vector2(-1, -2)
			3:
				arm_offset = Vector2(-2, -1)
			4:
				arm_offset = Vector2(-2, 1)
			5:
				arm_offset = Vector2(-1, 2)
			6:
				arm_offset = Vector2(1, 2)
			7:
				arm_offset = Vector2(2, 1)
		position = arm_offset

func _angle_to_index(angle):
	const CONVERSION_FACTOR = 8.0 / TAU
	const ADDITION_IF_NEGATIVE = TAU
	angle = fmod(angle, TAU)
	if angle > 0: angle = TAU - angle
	if angle < 0: angle = -angle
	var index = roundi(CONVERSION_FACTOR * angle)
	return index
	
func _add_all_willow_arms():
	match willow_num_arms:
		2:
			_add_willow_arm(7)
			_add_willow_arm(4)
		3:
			_add_willow_arm(0)
			_add_willow_arm(3)
			_add_willow_arm(6)
		5:
			_add_willow_arm(1)
			_add_willow_arm(2)
			_add_willow_arm(4)
			_add_willow_arm(6)
			_add_willow_arm(7)
		8:
			for i in range(8):
				_add_willow_arm(i)

func _add_willow_arm(index):
	var arm : Plant = plant_scene.instantiate()
	arm.type = Type.WILLOW_ARM
	arm.willow_arm_root_index = index
	add_child(arm)
	

#endregion: Willow functions

#region: Eggplant functions
func fire_eggplant():
	var eggplant = eggplant_scene.instantiate()
	eggplant.rotation = eggplant_spawn_angle
	eggplant.position = eggplant_spawn_pos + global_position
	main.food_holder.add_child(eggplant)
	
	const DUR = 1.25
	var half_dur = DUR / 2.0
	var final_pos = Vector2(randf_range(-16, 16), randf_range(-9, 9)) + main.food_supply_height
	
	var scale_tween = eggplant.create_tween()
	scale_tween.tween_property(eggplant, "scale", Vector2(1.25, 1.25), half_dur).set_trans(Tween.TRANS_LINEAR)
	scale_tween.tween_property(eggplant, "scale", Vector2(1.0, 1.0), half_dur).set_trans(Tween.TRANS_LINEAR)
	
	var rot_tween = eggplant.create_tween()
	rot_tween.tween_property(eggplant, "rotation", randf_range(TAU - 0.4, TAU + 0.4), DUR)
	rot_tween.tween_callback(eggplant_arrive.bind(eggplant))
	
	Utils.tween_arc_between(eggplant, eggplant.position, final_pos, DUR)

func eggplant_arrive(eggplant):
	const BOUNCE_HEIGHT = 2.0
	const BOUNCE_DUR = 0.2
	var bounce_tween = eggplant.create_tween()
	bounce_tween.tween_property(eggplant, "global_position:y", eggplant.global_position.y - BOUNCE_HEIGHT, BOUNCE_DUR).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(eggplant, "global_position:y", eggplant.global_position.y, BOUNCE_DUR).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	main.receive_food()
	create_tween().tween_property(eggplant, "rotation", lerp_angle(eggplant.rotation, 0.0 if randf() > 0.5 else PI, 0.9), BOUNCE_DUR).set_trans(Tween.TRANS_SINE)
#endregion: Eggplant functions





func _on_animation_finished():
	var grow_str = anim_str + "grow"
	var attack_str = anim_str + "shoot" + _get_willow_arm_string()
	var attack_str_front = attack_str + "_front"
	var attack_str_back = attack_str + "_back"
	match animation:
		grow_str:
			growing = false
			if type == Type.WILLOW: _add_all_willow_arms()
			retarget()
			if target: _attack(false)
		attack_str:
			animation = anim_str + "idle" + _get_willow_arm_string()
			_set_willow_arm_offset()
			if type == Type.POTATO:
				fire_condition_met.emit()
		attack_str_front:
			animation = anim_str + "idle_front"
		attack_str_back:
			animation = anim_str + "idle_back"


func _on_animation_looped():
	if type == Type.WILLOW_ARM:
		move_towards_root_anim()
	else:
		match animation: 
			"eggplant_idle":
				fire_eggplant()


func _on_attack_area_area_entered(area):
	if can_attack:
		var parent = area.get_parent()
		if parent is Insect:
			target_options.append(parent)
			if not (attacking or growing or not attack_timer.is_stopped()):
				retarget()
				_attack(false)


func _on_attack_area_area_exited(area):
	var parent = area.get_parent()
	if parent is Insect:
		target_options.erase(parent)
		if target and parent == target:
			target = null
			retarget()


func _on_frame_changed():
	match type:
		Type.PEPPER:
			if animation == anim_str + "shoot" and frame == 4:
				pause()
				if fired_projectile and is_instance_valid(fired_projectile):
					await fired_projectile.chase_complete
				play()


func _on_sleep_timer_timeout():
	sleeping = true
	if type == Type.WILLOW:
		for child in get_children():
			sleeping = true
	sleep_effect.show()
