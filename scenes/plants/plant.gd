extends AnimatedSprite2D
class_name Plant

#region: Global vars
enum Type {EGGPLANT, BROCCOLI, FOOD_SUPPLY}
enum Level {Level0, Level1, Level2, Level3}


const PROJECTILE_OFFSET = Vector2(-4, 2)

signal died

var type : Type = Type.EGGPLANT

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
var is_dead := false
#endregion: Global vars

#region: Eggplant vars
signal eggplant_arrived
var eggplant_scene : PackedScene = preload("res://scenes/plants/eggplant.tscn")
var eggplant_spawn_pos = Vector2(12, -13)
var eggplant_spawn_angle = -PI / 4.0
#endregion: Eggplant vars


#region: Other vars
var projectile_scene : PackedScene = preload("res://scenes/plants/projectile.tscn")
var hoe_tween : Tween
var target : Insect
var target_options : Array[Insect] = []
var attack_dir : Vector2
var attacking := false
var growing := true
var paused := false
var facing_right := randf() > 0.5
var facing_down := true
#endregion: Other vars

@onready var attack_timer : ScalableTimer = $AttackTimer
@onready var main : Main = get_tree().get_first_node_in_group("main")
@onready var floor : TileMapLayer = get_tree().get_first_node_in_group("floor")
#region: Universal functions
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pick_starting_animation()
	pick_stats()

func pick_stats():
	damage = Utils.get_plant_damage(type)
	health = Utils.get_plant_health(type)
	attack_range = Utils.get_plant_range(type)
	attack_cooldown = Utils.get_plant_attack_cooldown(type)
	match type:
		Type.FOOD_SUPPLY:
			health = 100
			attack_range = 0
		Type.EGGPLANT:
			flip_h = facing_right
		Type.BROCCOLI:
			projectile_lifespan = 0.7
			projectile_radius = 3
			projectile_speed = 90.0
					
	Utils.set_range_area_radii($AttackArea/CollisionShape2D, attack_range)

func _do_attack_cooldown():
	attack_timer.start(attack_cooldown)
	await attack_timer.timeout

func pick_starting_animation():
	match type:
		Type.EGGPLANT:
			animation = "eggplant_grow"
		Type.BROCCOLI:
			animation = "broccoli_grow"
		Type.FOOD_SUPPLY:
			animation = "none"
	play()

func on_hit_by_hoe(duration, start_strength, end_strength):
	# TODO wakeup if sleeping, display such
	var start_modulate = Color(start_strength, start_strength, start_strength, 1)
	var end_modulate = Color(end_strength, end_strength, end_strength, 1)
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
	hoe_tween.tween_property(self, "modulate", Color(1,1,1,1), 0.5).set_trans(Tween.TRANS_CUBIC)
	

func _physics_process(delta) -> void:
	if paused:
		speed_scale = 0
	elif is_dead:
		speed_scale = 1
	else:
		speed_scale = upgrade_fire_rate_mod * hoe_fire_rate_mod
	attack_timer.speed_scale = speed_scale
	calc_facing_vars()
	pick_animation()

func _attack(bypass : bool):
	if (not attacking) or bypass:
		attacking = true
		calc_facing_vars()
		var current_target = target
		match type:
			Type.BROCCOLI:
				fire_projectile()
				animation = "broccoli_shoot_front" if facing_down else "broccoli_shoot_back"
				frame = 0
				play()
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
	
	if target:
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
		Type.BROCCOLI:
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
			
			main.add_child.call_deferred(projectile)


func pick_animation():
	flip_h = facing_right
	if not growing:
		match type:
			Type.BROCCOLI:
				if not attacking and not (animation == "broccoli_shoot_front" or animation == "broccoli_shoot_back"):
					animation = "broccoli_idle_front" if facing_down else "broccoli_idle_back"
		play()

func calc_facing_vars():
	if target:
		attack_dir = position.direction_to(target.position) # FIXME could be expensive
		facing_right = attack_dir.x >= 0.0
		facing_down = attack_dir.y >= 0.0 


func take_damage(amount : int):
	health -= amount
	if health <= 0:
		die()

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
	match animation:
		"eggplant_grow":
			animation = "eggplant_shoot"
			play()
		"broccoli_grow":
			growing = false
			retarget()
			if target: _attack(false)
		"broccoli_shoot_front":
			animation = "broccoli_idle_front"
			play()
		"broccoli_shoot_back":
			animation = "broccoli_idle_back"
			play()


func _on_animation_looped():
	match animation: 
		"eggplant_shoot":
			fire_eggplant()


func _on_attack_area_area_entered(area):
	var parent = area.get_parent()
	if parent is Insect:
		target_options.append(parent)
		if not (attacking or growing):
			retarget()
			_attack(false)


func _on_attack_area_area_exited(area):
	var parent = area.get_parent()
	if parent is Insect:
		target_options.erase(parent)
		if target and parent == target:
			target = null
			retarget()
