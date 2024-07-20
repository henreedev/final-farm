extends Control
class_name UpgradeMenu
var is_open := false


@onready var main : Main = get_tree().get_first_node_in_group("main")
@onready var player : Player = get_tree().get_first_node_in_group("player")
@onready var shop_inventory : ShopInventory = $MarginContainer/TextureRect/InventoryRoot/ShopInventory

func _ready():
	set_process(false)
	modulate = Color(1,1,1,0)

func _input(event):
	if event.is_action_pressed("escape_menu"):
		close()

func open():
	if not is_open:
		is_open = true
		set_process(true)
		show()
		if main.upgrade_menu_tween:
			main.upgrade_menu_tween.kill()
		main.upgrade_menu_tween = create_tween().set_parallel()
		main.upgrade_menu_tween.tween_property(self, "modulate", Color(1,1,1,1), 1.0).set_delay(0.25).set_trans(Tween.TRANS_CUBIC)
		main.upgrade_menu_tween.tween_property(player, "target_zoom_override", Vector2(10,10), 0.0)

func close():
	await get_tree().create_timer(0.05).timeout
	if is_open:
		is_open = false
		set_process(false)
		if main.upgrade_menu_tween:
			main.upgrade_menu_tween.kill()
		main.upgrade_menu_tween = create_tween().set_parallel()
		main.upgrade_menu_tween.tween_property(self, "modulate", Color(1,1,1,0), 0.25)
		main.upgrade_menu_tween.tween_property(player, "target_zoom_override", Vector2(0,0), 0)
		main.upgrade_menu_tween.tween_callback(hide).set_delay(0.25)
