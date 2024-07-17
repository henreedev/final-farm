extends AnimatedSprite2D
class_name SeedBag

var type : Plant.Type = Plant.Type.EGGPLANT
@onready var player : Player = get_tree().get_first_node_in_group("player")
@onready var main = get_tree().get_first_node_in_group("main")
@onready var floor : TileMapLayer = get_tree().get_first_node_in_group("floor")
var plant_scene : PackedScene = preload("res://scenes/plants/plant.tscn")
var thrown = false
var arrived = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pick_animation()
	create_tween().tween_property(self, "scale", Vector2(0.5, 0.5), 0.5).set_trans(Tween.TRANS_CUBIC)

func delete():
	reparent(main)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0, 0), 0.2).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(queue_free)

func throw(final_pos, duration):
	reparent(main)
	thrown = true
	_set_tile_unplantable(final_pos)
	create_tween().tween_property(self, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_CUBIC)
	Utils.tween_arc_between(self, global_position, final_pos, duration)
	create_tween().tween_callback(arrive).set_delay(duration)

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

func _finish():
	play()
	_create_plant()
	await animation_finished
	queue_free()

func _create_plant():
	var plant : Plant = plant_scene.instantiate()
	plant._type = type
	plant.position = global_position
	main.add_child(plant)

func pick_animation():
	match type:
		Plant.Type.EGGPLANT:
			animation = "eggplant_tear"
		_:
			print("SEED TYPE ANIMATION NOT DEFINED (seed_bag.gd)")
