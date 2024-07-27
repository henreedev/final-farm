extends Node2D
class_name ShopInventory

var close_enough = false
var target_pos : Vector2
var selected_type : Plant.Type = Plant.Type.BROCCOLI
var selected_bag : ShopBag
var plant_types_len = len(Plant.Type)
var types_to_bags := {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for child : ShopBag in get_children():
		types_to_bags[child.type] = child

func _input(event):
	if event.is_action_released("scroll_up") or event.is_action_released("scroll_down"):
		var scroll_dir = 0
		if event.is_action_released("scroll_up"):
			scroll_dir -= 1
		elif event.is_action_released("scroll_down"):
			scroll_dir += 1
		_update_selection(clampi(selected_type + scroll_dir, 0, plant_types_len - 3)) # -1 , -1 for FOOD_SUPPLY, -1 for WILLOW_ARM

func _update_selection(new_selected_type):
	close_enough = false
	selected_type = new_selected_type
	target_pos = -types_to_bags[selected_type].position
	for bag : ShopBag in types_to_bags.values():
		if bag != types_to_bags[selected_type] and bag.is_selected:
			bag._on_mouse_zone_mouse_exited()


func _process(delta):
	const STR = 5.0
	const BASE = 0.2
	if not close_enough:
		var dist2 = clampf(position.distance_squared_to(target_pos), 0, 1)
		position = lerp(position, target_pos, dist2 * delta * STR + BASE * delta)
		if dist2 < 0.01:
			close_enough = true
