extends AnimatedSprite2D
class_name SeedBag

signal spawn_plant

var type : Plant.Type = Plant.Type.EGGPLANT

var thrown_to_player := false
var prog_to_player := 0.0
var throw_duration = 1.0

var thrown = false
var arrived = false


var plant_scene : PackedScene = load("res://scenes/plants/plant.tscn")
@onready var player : Player = get_tree().get_first_node_in_group("player")
var shop : Shop
@onready var main : Main = get_tree().get_first_node_in_group("main")
@onready var floor : TileMapLayer = get_tree().get_first_node_in_group("floor")

# Called when the node enters the scene tree for the first time.
func _ready():
	pick_animation()
	if not thrown_to_player:
		create_tween().tween_property(self, "scale", Vector2(0.5, 0.5), 0.5).set_trans(Tween.TRANS_CUBIC)
	else:
		shop = get_tree().get_first_node_in_group("shop")
		create_tween().tween_property(self, "prog_to_player", 1.0, throw_duration)
		var half_dur = throw_duration / 2.0
		var scale_tween = create_tween()
		var rot_tween = create_tween()
		scale_tween.tween_property(self, "scale", Vector2(0.75, 0.75), half_dur).set_trans(Tween.TRANS_LINEAR)
		scale_tween.tween_property(self, "scale", Vector2(0.6, 0.6), half_dur).set_trans(Tween.TRANS_LINEAR)
		rot_tween.tween_property(self, "rotation", randf_range(TAU - 0.4, TAU + 0.4), throw_duration)
		rot_tween.tween_callback(delete)
		rot_tween.tween_callback(player.receive_seed.bind(type))
		

func delete():
	reparent(main)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0, 0), 0.2).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(queue_free)

func throw(final_pos, duration):
	reparent(main)
	thrown = true
	_set_tile_unplantable(final_pos)
	var half_dur = duration / 2.0
	var scale_tween = create_tween()
	var rot_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2(1.0, 1.0), half_dur).set_trans(Tween.TRANS_LINEAR)
	scale_tween.tween_property(self, "scale", Vector2(0.75, 0.75), half_dur).set_trans(Tween.TRANS_LINEAR)
	rot_tween.tween_property(self, "rotation", randf_range(TAU - 0.4, TAU + 0.4), duration)
	rot_tween.tween_callback(arrive)
	Utils.tween_arc_between(self, global_position, final_pos, duration)

func _set_tile_unplantable(final_pos):
	var coords = floor.local_to_map(final_pos)
	floor.set_cell(coords, 0, Vector2i(3, 1))

func arrive():
	arrived = true
	const BOUNCE_HEIGHT = 5
	const BOUNCE_DUR = 0.25
	var tween = create_tween()
	tween.tween_property(self, "global_position:y", global_position.y - BOUNCE_HEIGHT, BOUNCE_DUR).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position:y", global_position.y, BOUNCE_DUR).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(_finish)
	create_tween().tween_property(self, "rotation", lerp_angle(rotation, 0, 0.99), BOUNCE_DUR).set_trans(Tween.TRANS_SINE)

func _finish():
	play()
	await spawn_plant
	_spawn_plant()
	await animation_finished
	queue_free()

func _spawn_plant():
	var plant : Plant = plant_scene.instantiate()
	plant.type = type
	plant.position = global_position
	plant.paused = main.plants_paused
	main.add_child(plant)

func pick_animation():
	match type:
		Plant.Type.EGGPLANT:
			animation = "eggplant_tear"
		Plant.Type.BROCCOLI:
			animation = "broccoli_tear"
		_:
			print("SEED TYPE ANIMATION NOT DEFINED (seed_bag.gd)")

func _on_frame_changed():
	if frame == 5:
		spawn_plant.emit()

func _process(_delta):
	if thrown_to_player:
		global_position = Utils.calc_point_on_arc_between(shop.global_position + Vector2(-2, 2), player.global_position + Vector2(0, -16), prog_to_player)
		
