extends AnimatedSprite2D
class_name Plant

#region: Global vars
enum Type {EGGPLANT, BROCCOLI, FOOD_SUPPLY}
enum Level {Level1, Level2, Level3A, Level3B}
signal died

var type : Type = Type.EGGPLANT
var level : Level = Level.Level1

var cost : int
var health : int
var time_to_grow : int
var damage : int
var attack_range : int
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
var hoe_tween : Tween
#endregion: Other vars
@onready var attack_timer : Timer = $AttackTimer
@onready var main : Main = get_tree().get_first_node_in_group("main")
@onready var floor : TileMapLayer = get_tree().get_first_node_in_group("floor")
#region: Universal functions
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pick_animation()
	pick_stats()

func pick_stats():
	match type:
		Type.EGGPLANT:
			cost = 5
			health = 100
			attack_range = 0
		Type.FOOD_SUPPLY:
			health = 100
			attack_range = 0
		Type.BROCCOLI:
			health = 100
			damage = 1
			attack_range = 3
			attack_cooldown = 1.0
	Utils.set_range_area_radii($AttackArea/CollisionShape2D, attack_range)

func _do_attack_cooldown():
	attack_timer.start(attack_cooldown)
	await attack_timer.timeout

func pick_animation():
	match type:
		Type.EGGPLANT:
			animation = "eggplant_grow"
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
	speed_scale = (upgrade_fire_rate_mod * hoe_fire_rate_mod) if not is_dead else 1

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
	create_tween().tween_property(eggplant, "rotation", lerp_angle(eggplant.rotation, 0 if randf() > 0.5 else PI, 0.9), BOUNCE_DUR).set_trans(Tween.TRANS_SINE)
#endregion: Eggplant functions





func _on_animation_finished():
	match animation:
		"eggplant_grow":
			animation = "eggplant_shoot"
			play()
		"broccoli_attack_front":
			animation = "broccoli_idle_front"
			play()
		"broccoli_attack_back":
			animation = "broccoli_idle_back"
			play()


func _on_animation_looped():
	match animation: 
		"eggplant_shoot":
			fire_eggplant()


func _on_attack_timer_timeout():
	attack_timer.start(0.1)
