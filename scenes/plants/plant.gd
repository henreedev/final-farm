extends AnimatedSprite2D
class_name Plant

enum Type {EGGPLANT}
var _type : Type = Type.EGGPLANT
var cost : int
var health : int
var time_to_grow : int
var damage : int
var range : int
var fire_rate_mod := 1.0
var is_sleeping := false
var health_decay := 60
@onready var floor : TileMapLayer = get_tree().get_first_node_in_group("floor")
#region: Universal functions
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pick_animation()
	pick_stats()

func pick_stats():
	match _type:
		Type.EGGPLANT:
			cost = 5
			health = 100

func pick_animation():
	match _type:
		Type.EGGPLANT:
			animation = "eggplant_grow"
	play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func die():
	var coords = floor.local_to_map(global_position)
	if coords: 
		var tile = floor.get_cell_tile_data(coords)
		if tile: 
			floor.set_cell(coords, 0, Vector2i(0, 0))
	queue_free()
#endregion: Universal functions


#region: Eggplant functions
func fire_eggplant():
	print("Firing eggplant")

#endregion: Eggplant functions





func _on_animation_finished():
	match animation:
		"eggplant_grow":
			animation = "eggplant_shoot"
			play()


func _on_animation_looped():
	match animation: 
		"eggplant_shoot":
			fire_eggplant()
