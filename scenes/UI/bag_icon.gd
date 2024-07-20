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
@onready var player : Player = get_tree().get_first_node_in_group("player")
@onready var inventory : Inventory = get_parent()
@onready var label : Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	Utils.give_zoom_shader(self)
	initial_scale = scale
	match type:
		Plant.Type.EGGPLANT:
			animation = "eggplant"
		Plant.Type.BROCCOLI:
			animation = "broccoli"
		_:
			print("SEED TYPE ANIMATION NOT DEFINED (bag_icon.gd)")

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
	selected = self == inventory.selected_icon
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
