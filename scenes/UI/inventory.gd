extends Node2D
class_name Inventory

var icons : Array[BagIcon] = []
var seen_types := {}
var next_icon_pos := Vector2(0, 0)
const ICON_HOZ_OFFSET = 150.0
var target_pos
var selected_icon_index := 0
var selected_icon : BagIcon
var selected_type : Plant.Type
var bag_icon_scene : PackedScene = preload("res://scenes/UI/bag_icon.tscn")

@onready var player : Player = get_tree().get_first_node_in_group("player")

# Called when the node enters the scene tree for the first time.
func _ready():
	player.seed_count_changed.connect(on_player_seed_counts_change)
	_add_icon(Plant.Type.EGGPLANT)

func on_player_seed_counts_change(type : Plant.Type):
	_add_icon(type)
	_update_icons()

func _update_icons():
	_update_selection()
	for icon in icons:
		icon.update()

func _add_icon(type : Plant.Type):
	if not seen_types or not seen_types[type]:
		# First time seeing seed
		seen_types[type] = true
		var bag_icon : BagIcon = bag_icon_scene.instantiate()
		bag_icon.type = type
		icons.append(bag_icon)
		bag_icon.position = next_icon_pos
		next_icon_pos += Vector2(ICON_HOZ_OFFSET, 0)
		add_child(bag_icon)

func _input(event):
	var scroll_dir = 0
	if event.is_action_released("scroll_up"):
		scroll_dir -= 1
	elif event.is_action_released("scroll_down"):
		scroll_dir += 1
	selected_icon_index = selected_icon_index + scroll_dir
	var set_seed_index = -1
	if event.is_action_pressed("select_seed_0"):
		set_seed_index = 0
	if event.is_action_pressed("select_seed_1"):
		set_seed_index = 1
	if event.is_action_pressed("select_seed_2"):
		set_seed_index = 2
	if event.is_action_pressed("select_seed_3"):
		set_seed_index = 3
	if event.is_action_pressed("select_seed_4"):
		set_seed_index = 4
	if event.is_action_pressed("select_seed_5"):
		set_seed_index = 5
	if event.is_action_pressed("select_seed_6"):
		set_seed_index = 6
	if event.is_action_pressed("select_seed_7"):
		set_seed_index = 7
	if event.is_action_pressed("select_seed_8"):
		set_seed_index = 8
	if event.is_action_pressed("select_seed_9"):
		set_seed_index = 9
	if not set_seed_index < 0:
		selected_icon_index = set_seed_index
	selected_icon_index = clampi(selected_icon_index, 0, len(icons) - 1)
	_update_icons()

func _update_selection():
	selected_icon = icons[selected_icon_index]
	selected_type = selected_icon.type
	player.equipped_seed_type = selected_type
	target_pos = -selected_icon.position
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	const STR = 5.0
	const BASE = 0.2
	var dist2 = clampf(position.distance_squared_to(target_pos), 0, 1)
	position = lerp(position, target_pos, dist2 * delta * STR + BASE * delta)
