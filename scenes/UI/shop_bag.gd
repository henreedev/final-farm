extends AnimatedSprite2D
class_name ShopBag
signal selected

var is_selected := false
var discovered_first_time := false
@export var type : Plant.Type
var blurb_tween : Tween
var bag_tween : Tween
var name_tween : Tween
var showing_upgrade := false
const name_zoomed_scale = Vector2(0.035, .035)
const name_big_scale = Vector2(0.125, .125)
const name_big_pos = Vector2(-105, -13)
const name_zoomed_pos = Vector2(-105, -6)
var initial_scale : Vector2

var rainbow_gradient : GradientTexture1D = preload("res://scenes/UI/rainbow-gradient.tres")
var first_time_setting_rainbow := true

@onready var name_label : Label = $NameLabel
@onready var main : Main = get_tree().get_first_node_in_group("main")
@onready var shop_inventory  = get_parent()
@onready var player : Player = get_tree().get_first_node_in_group("player")
@onready var hidden_stuff = $Hidden
@onready var blurb : Node2D = $Blurb
@onready var hidden_label : Label = $Hidden/Label
@onready var buy_button : TextureButton = $Blurb/BuyButton
@onready var buy_label : Label = $Blurb/BuyButton/Label
@onready var upgrade_label : Label = $Blurb/UpgradeButton/Label
@onready var upgrade_label_icon : Sprite2D = $Blurb/UpgradeButton/Sprite2D
@onready var upgrade_button : TextureButton = $Blurb/UpgradeButton
@onready var damage_icon : Sprite2D = $Blurb/AttackIcon
@onready var health_icon : Sprite2D = $Blurb/HealthIcon
@onready var range_icon : Sprite2D = $Blurb/RangeIcon
@onready var atk_spd_icon : Sprite2D = $Blurb/AtkSpdIcon
@onready var spawn_dur_icon : Sprite2D = $Blurb/SpawnTimeIcon
@onready var special_icon : Sprite2D = $Blurb/SpecialIcon
@onready var damage_label : Label = $Blurb/AttackIcon/Label
@onready var health_label : Label = $Blurb/HealthIcon/Label
@onready var range_label : Label = $Blurb/RangeIcon/Label
@onready var attack_speed_label : Label = $Blurb/AtkSpdIcon/Label
@onready var spawn_duration_label : Label = $Blurb/SpawnTimeIcon/Label
@onready var special_label : Label = $Blurb/SpecialIcon/Label
@onready var damage_blurb : Label = $Blurb/AttackIcon/Info
@onready var health_blurb : Label = $Blurb/HealthIcon/Info
@onready var range_blurb : Label = $Blurb/RangeIcon/Info
@onready var atk_spd_blurb : Label = $Blurb/AtkSpdIcon/Info
@onready var spawn_dur_blurb : Label = $Blurb/SpawnTimeIcon/Info
@onready var special_blurb : Label = $Blurb/SpecialIcon/Info
@onready var upgrade_1_label : Label = $Blurb/UpgradeIcon1/Info
@onready var upgrade_1_icon : AnimatedSprite2D = $Blurb/UpgradeIcon1
@onready var upgrade_2_label : Label = $Blurb/UpgradeIcon2/Info
@onready var upgrade_2_icon : AnimatedSprite2D = $Blurb/UpgradeIcon2
@onready var upgrade_3_label : Label = $Blurb/UpgradeIcon3/Info
@onready var upgrade_3_icon : AnimatedSprite2D = $Blurb/UpgradeIcon3
@onready var info_blurb : Label = $Blurb/Info
@onready var shop : Shop = get_tree().get_first_node_in_group("shop")
@onready var cost = Utils.get_plant_cost(type)
# Called when the node enters the scene tree for the first time.
func _ready():
	hidden_stuff.show()
	damage_blurb.hide()
	health_blurb.hide()
	range_blurb.hide()
	atk_spd_blurb.hide()
	spawn_dur_blurb.hide()
	special_blurb.hide()
	upgrade_1_label.hide()
	upgrade_2_label.hide()
	upgrade_3_label.hide()
	set_rainbow([damage_icon, health_icon, range_icon, atk_spd_icon, spawn_dur_icon, special_icon])
	blurb.modulate = Color(1,1,1,0)
	name_label.scale = name_big_scale
	name_label.position = name_big_pos
	initial_scale = scale
	pick_animation()
	_update_bag_values(true)
	player.total_seeds_changed.connect(update)
	player.bug_kills_changed.connect(update)

func set_rainbow(sprite_list : Array[Sprite2D], rainbow_on := true):
	for sprite : Sprite2D in sprite_list:
		if first_time_setting_rainbow:
			Utils.give_zoom_shader(sprite)
			sprite.material.set_shader_parameter("gradient", rainbow_gradient)
			sprite.material.set_shader_parameter("scroll_speed", -1.4)
			sprite.material.set_shader_parameter("use_gradient", true)
		else:
			print("turning ", rainbow_on)
			sprite.material.set_shader_parameter("outline_active", rainbow_on)
	first_time_setting_rainbow = false

func update():
	buy_label.text = str(cost)
	var upgrade_cost = Utils.get_next_upgrade_cost(type)
	if upgrade_cost > 0:
		upgrade_label.text = str(upgrade_cost)
	else:
		upgrade_label.text = ""
		upgrade_label_icon.hide()
		
	if player.total_seeds >= cost and cost > 0:
		# player has enough to buy
		if not discovered_first_time:
			discover()
		buy_button.disabled = false
	else: 
		hidden_label.text = str(cost)
		buy_button.disabled = true
	
	if player.bug_kills >= upgrade_cost and upgrade_cost > 0:
		upgrade_button.disabled = false
	else:
		upgrade_button.disabled = true

func discover():
	discovered_first_time = true
	hidden_stuff.hide()
	_update_bag_values(true)
	# TODO Play a noise, make the shop indicate something  

func pick_animation():
	animation = Utils.get_plant_string(type)

func _update_bag_values(is_first_time := false):
	var changed_icons : Array[Sprite2D] = []
	const prefix = ": "
	var damage_label_text = prefix + str(Utils.get_plant_damage(type))
	if showing_upgrade:
		if damage_label_text != damage_label.text:
			changed_icons.append(damage_icon)
	damage_label.text = damage_label_text
	var health_label_text = prefix + str(Utils.get_plant_health(type))
	if showing_upgrade:
		if health_label_text != health_label.text:
			changed_icons.append(health_icon)
	health_label.text = health_label_text
	var range_label_text = prefix + str(Utils.get_plant_range(type)) + " tiles"
	if showing_upgrade:
		if range_label_text != range_label.text:
			changed_icons.append(range_icon)
	range_label.text = range_label_text
	var attack_speed_label_text = prefix + str(Utils.get_plant_attack_cooldown(type)) + " sec"
	if showing_upgrade:
		if attack_speed_label_text != attack_speed_label.text:
			changed_icons.append(atk_spd_icon)
	attack_speed_label.text = attack_speed_label_text
	var spawn_duration_label_text = prefix + str(Utils.get_plant_spawn_duration(type)) + " sec"
	if showing_upgrade:
		if spawn_duration_label_text != spawn_duration_label.text:
			changed_icons.append(spawn_dur_icon)
	spawn_duration_label.text = spawn_duration_label_text
	var special_label_text = prefix + str(Utils.get_plant_special_value(type))
	if showing_upgrade:
		if special_label_text != special_label.text:
			changed_icons.append(special_icon)
	special_label.text = special_label_text
	if discovered_first_time:
		name_label.text = Utils.get_plant_display_string(type)
	else:
		name_label.text = "???"
	if is_first_time:
		special_blurb.text = Utils.get_plant_special_blurb(type)
		upgrade_1_label.text = Utils.get_plant_upgrade_blurb(type, Plant.Level.Level1)
		upgrade_2_label.text = Utils.get_plant_upgrade_blurb(type, Plant.Level.Level2)
		upgrade_3_label.text = Utils.get_plant_upgrade_blurb(type, Plant.Level.Level3)
		info_blurb.text = Utils.get_plant_blurb(type)
	match Utils.get_plant_level(type):
		Plant.Level.Level0:
			upgrade_1_icon.animation = "inactive"
			upgrade_2_icon.animation = "inactive"
			upgrade_3_icon.animation = "inactive"
		Plant.Level.Level1:
			upgrade_1_icon.animation = "active"
			upgrade_2_icon.animation = "inactive"
			upgrade_3_icon.animation = "inactive"
		Plant.Level.Level2:
			upgrade_1_icon.animation = "active"
			upgrade_2_icon.animation = "active"
			upgrade_3_icon.animation = "inactive"
		Plant.Level.Level3:
			upgrade_1_icon.animation = "active"
			upgrade_2_icon.animation = "active"
			upgrade_3_icon.animation = "active"
	return changed_icons

func _undo_upgrade():
	if showing_upgrade:
		showing_upgrade = false
		Utils.undo_temp_set_level(type)
		set_rainbow([damage_icon, health_icon, range_icon, \
			atk_spd_icon, spawn_dur_icon, special_icon], false)
		_update_bag_values()

func _show_upgrade(level : Plant.Level):
	if showing_upgrade:
		_undo_upgrade()
	showing_upgrade = true 
	Utils.temp_set_level(type, level)
	var different_icons : Array[Sprite2D] = _update_bag_values()
	set_rainbow(different_icons)
	

func _on_mouse_zone_mouse_entered():
	is_selected = true
	shop_inventory._update_selection(type)
	play()
	if bag_tween:
		bag_tween.kill()
	bag_tween = create_tween().set_parallel()
	var scale_factor = 1.2 if not discovered_first_time else 3.0
	bag_tween.tween_property(self, "scale", initial_scale * scale_factor, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if discovered_first_time:
		if name_tween:
			name_tween.kill()
		name_tween = create_tween().set_parallel()
		name_tween.tween_property(name_label, "position", name_zoomed_pos, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		name_tween.tween_property(name_label, "scale", name_zoomed_scale, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_mouse_zone_mouse_exited():
	is_selected = false
	if bag_tween:
		bag_tween.kill()
	bag_tween = create_tween().set_parallel()
	bag_tween.tween_property(self, "scale", initial_scale, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if discovered_first_time:
		if name_tween:
			name_tween.kill()
		name_tween = create_tween().set_parallel()
		name_tween.tween_property(name_label, "position", name_big_pos, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		name_tween.tween_property(name_label, "scale", name_big_scale, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
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


func _on_buy_button_pressed():
	var cost = Utils.get_plant_cost(type)
	if cost > 0:
		player.adjust_total_seeds(-cost)
		player.receive_seed(type)


func _on_upgrade_button_pressed():
	var cost = Utils.get_next_upgrade_cost(type)
	if cost > 0 and player.bug_kills - cost >= 0:
		player.adjust_bug_kills(-cost)
		Utils.upgrade(type)
		_update_bag_values(false)
		update()
		for plant : Plant in get_tree().get_nodes_in_group("plant"):
			if plant.type == type:
				plant.on_upgrade()


func _on_area_2d_mouse_entered():
	special_blurb.show()
	damage_blurb.show()
	health_blurb.show()
	range_blurb.show()
	atk_spd_blurb.show()
	spawn_dur_blurb.show()

func _on_area_2d_mouse_exited():
	special_blurb.hide()
	damage_blurb.hide()
	health_blurb.hide()
	range_blurb.hide()
	atk_spd_blurb.hide()
	spawn_dur_blurb.hide()

func _on_upgrade_1_area_mouse_entered():
	upgrade_1_label.show()
	_show_upgrade(Plant.Level.Level1)

func _on_upgrade_1_area_mouse_exited():
	upgrade_1_label.hide()
	_undo_upgrade()

func _on_upgrade_2_area_mouse_entered():
	upgrade_2_label.show()
	_show_upgrade(Plant.Level.Level2)

func _on_upgrade_2_area_mouse_exited():
	upgrade_2_label.hide()
	_undo_upgrade()

func _on_upgrade_3_area_mouse_entered():
	upgrade_3_label.show()
	_show_upgrade(Plant.Level.Level3)

func _on_upgrade_3_area_mouse_exited():
	upgrade_3_label.hide()
	_undo_upgrade()
