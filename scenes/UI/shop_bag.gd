extends AnimatedSprite2D
class_name ShopBag
signal selected

var is_selected := false
var discovered_first_time := false
@export var type : Plant.Type
var blurb_tween : Tween
var bag_tween : Tween
var initial_scale : Vector2
@onready var shop_inventory  = get_parent()
@onready var player : Player = get_tree().get_first_node_in_group("player")
@onready var hidden_stuff = $Hidden
@onready var blurb : Node2D = $Blurb
@onready var hidden_label : Label = $Hidden/Label
@onready var buy_button : TextureButton = $Blurb/BuyButton
@onready var buy_label : Label = $Blurb/BuyButton/Label
@onready var upgrade_label : Label = $Blurb/UpgradeButton/Label
@onready var upgrade_button : TextureButton = $Blurb/UpgradeButton
@onready var shop : Shop = get_tree().get_first_node_in_group("shop")
# Called when the node enters the scene tree for the first time.
func _ready():
	blurb.modulate = Color(1,1,1,0)
	initial_scale = scale
	pick_animation()
	player.total_seeds_changed.connect(update)
	player.bug_kills_changed.connect(update)

func update():
	var cost = Utils.get_cost_of_type(type)
	var upgrade_cost = Utils.get_cost_of_next_upgrade(type)
	upgrade_label.text = str(upgrade_cost)
	buy_label.text = str(cost)
	if player.total_seeds >= cost:
		# player has enough to buy
		if not discovered_first_time:
			discover()
		buy_button.disabled = false
	else: 
		hidden_label.text = str(cost)
		buy_button.disabled = true
	
	if player.bug_kills >= upgrade_cost:
		upgrade_button.disabled = false

func discover():
	discovered_first_time = true
	hidden_stuff.hide()
	# TODO Play a noise, make the shop indicate something  

func pick_animation():
	match type: # TODO add all plants
		Plant.Type.EGGPLANT:
			animation = "eggplant"
		Plant.Type.BROCCOLI:
			animation = "broccoli"

func _on_mouse_zone_mouse_entered():
	print("inside of type ", type)
	is_selected = true
	shop_inventory._update_selection(type)
	play()
	if bag_tween:
		bag_tween.kill()
	bag_tween = create_tween().set_parallel()
	bag_tween.tween_property(self, "scale", initial_scale * 3, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

func _on_mouse_zone_mouse_exited():
	print("outside of type ", type)
	is_selected = false
	if bag_tween:
		bag_tween.kill()
	bag_tween = create_tween().set_parallel()
	bag_tween.tween_property(self, "scale", initial_scale, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if blurb_tween:
		blurb_tween.kill()
	blurb_tween = create_tween()
	blurb_tween.tween_property(blurb, "modulate", Color(1,1,1,0), 0.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	blurb_tween.tween_callback(blurb.hide)
	blurb_tween.tween_callback(play_backwards.bind(animation))

func _on_animation_finished():
	if frame != 0 and discovered_first_time: 
		if blurb_tween:
			blurb_tween.kill()
		blurb_tween = create_tween()
		blurb_tween.tween_callback(blurb.show)
		blurb_tween.tween_property(blurb, "modulate", Color(1,1,1,1), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	


func _on_mouse_zone_input_event(viewport, event, shape_idx):
	print(viewport, event, shape_idx)


func _on_buy_button_pressed():
	player.adjust_total_seeds(Utils.get_cost_of_type(type))
	player.receive_seed(type)


func _on_upgrade_button_pressed():
	player.adjust_bug_kills(Utils.get_cost_of_next_upgrade(type))
	Utils.upgrade(type)
