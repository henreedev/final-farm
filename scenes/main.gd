extends Node2D
class_name Main
signal upgrade_purchased


const MAX_FOOD_HEIGHT = Vector2(0, -24)
const WINNING_FOOD_AMOUNT = 1000

@export var food_amount := 0
@export var passive_seed_income_per_wave := 5
@export var bugs_killed = 0

var food_pile_height = Vector2(0,0)

@onready var food_holder = $FoodHolder
@onready var player_ui: Control = $CanvasLayer/Player_UI
@onready var upgrade_menu: Control = $CanvasLayer/Upgrade_Menu
@onready var pause_menu: Control = $CanvasLayer/pause_menu

func _ready() -> void:
	connect_signals()

func connect_signals():
	upgrade_menu.check_if_purchasable.connect(_on_upgrade_menu_check_if_purchasable)

func receive_food():
	food_amount += 1
	var ratio = float(food_amount) / float(WINNING_FOOD_AMOUNT)
	food_pile_height = lerp(Vector2(0,0), MAX_FOOD_HEIGHT, ratio)
	food_pile_height.x = int(food_pile_height.x)
	food_pile_height.y = int(food_pile_height.y)
	print("food now = ", food_amount)
	if food_amount >= WINNING_FOOD_AMOUNT:
		win()

func win():
	print("dubski")


func _input(event: InputEvent):
	if not get_tree().paused:
		
		if Input.is_action_just_pressed("ui_cancel"):
			print("pausing game")
			get_tree().paused = true
			pause_menu.visible = true
			#toggle_game_paused.emit(true)


func _on_upgrade_menu_check_if_purchasable(upgrade_name: String, price: int) -> void:
	if bugs_killed >= price:
		bugs_killed -= price
		player_ui.bugs_killed = bugs_killed
		upgrade_purchased.emit(upgrade_name,price)
		print("emitting upgrade name of: ",upgrade_name)
	else:
		print("upgrade failed: not enough muns")


func _on_player_ui_bug_killed() -> void:
	bugs_killed+=1



func _on_test_open_shop_pressed() -> void:
	upgrade_menu.visible = true
	pass # Replace with function body.



func _on_pause_menu_unpausing_with_esc() -> void:
	get_tree().paused = false
	pause_menu.visible = false
