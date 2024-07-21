extends AnimatedSprite2D
class_name BagIcon

var type : Plant.Type 
var selected := false
var amount := 0
var empty := true


var dist_to_center_ratio : float
const FADE_CUTOFF := 300
var initial_scale : Vector2
var tint := Color(1,1,1)
var label_setting : LabelSettings = preload("res://scenes/UI/bag_icon.tres")
@onready var player : Player = get_tree().get_first_node_in_group("player")
@onready var inventory : Inventory = get_parent()
@onready var label : Label = $Label
@onready var main : Main = get_tree().get_first_node_in_group("main")
@onready var buy_icon : Sprite2D = $BuyIcon
# Called when the node enters the scene tree for the first time.
func _ready():
	label.label_settings = LabelSettings.new()
	label.label_settings.font = label_setting.font
	label.label_settings.font_color = label_setting.font_color
	label.label_settings.font_size = label_setting.font_size
	label.label_settings.shadow_color = label_setting.shadow_color
	label.label_settings.shadow_size = label_setting.shadow_size
	buy_icon.hide()
	Utils.give_zoom_shader(self)
	initial_scale = scale
	animation = Utils.get_plant_string(type)

func update():
	amount = player.seed_counts[type]
	label.text = str(amount)
	empty = amount <= 0
	if empty:
		tint = Color(0.8, 0.5, 0.5, 1)
		label.label_settings.font_color = tint
	else:
		tint = Color(1, 1, 1, 1)
		label.label_settings.font_color = tint
		if not inventory.seen_types[type]:
			main.shop_inventory.types_to_bags[type].discover()
	selected = self == inventory.selected_icon
	if not selected or player.total_seeds < Utils.get_plant_cost(type): 
		buy_icon.hide()
	else:
		buy_icon.show()
		if empty: buy_icon.modulate = Color(1.5,2,2,1)
		else: buy_icon.modulate = Color(1,1,1,1)
	material.set_shader_parameter("outline_1_active", selected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var dist_to_center = abs(global_position.x - get_viewport_rect().size.x / 2)
	if dist_to_center > FADE_CUTOFF:
		hide()
	else:
		show()
		dist_to_center_ratio = 1 - clampf(dist_to_center / FADE_CUTOFF, 0.0, 1.0)
		modulate = Color(tint.r,tint.g,tint.b,dist_to_center_ratio * 0.8)
		scale = initial_scale * Vector2(dist_to_center_ratio, dist_to_center_ratio)
