extends Node2D
class_name Main
signal upgrade_purchased



const MAX_FOOD_HEIGHT = Vector2(0, -24)
const WINNING_FOOD_AMOUNT = 1000

@export var food_amount := 0
@export var passive_seed_income_per_wave := 5
@export var bugs_killed = 0

var food_supply_height = Vector2(0,0)
var food_supply_plant : Plant 
var plant_scene : PackedScene = preload("res://scenes/plants/plant.tscn")
#var has_init_shop = false

@onready var food_holder = $FoodHolder
@onready var player_ui: Control = $CanvasLayer/Player_UI
@onready var upgrade_menu: Control = $CanvasLayer/Upgrade_Menu
@onready var pause_menu: Control = $CanvasLayer/pause_menu
var shop : Shop
func _ready() -> void:
	_init_vars()
	connect_signals()

func _process(delta: float) -> void:
	pass
		
func _init_vars():
	await get_tree().create_timer(0.01).timeout
	shop = get_tree().get_first_node_in_group("shop")
	pass
func connect_signals():
	await get_tree().create_timer(0.02).timeout
	shop.toggle_shop.connect(_toggle_shop)

func receive_food():
	food_amount += 1
	var ratio = float(food_amount) / float(WINNING_FOOD_AMOUNT)
	food_supply_height = lerp(Vector2(0,0), MAX_FOOD_HEIGHT, ratio)
	food_supply_height.x = int(food_supply_height.x)
	food_supply_height.y = int(food_supply_height.y)
	if not food_supply_plant:
		create_food_supply_plant()
	if food_amount >= WINNING_FOOD_AMOUNT:
		win()

func create_food_supply_plant():
	food_supply_plant = plant_scene.instantiate()
	food_supply_plant.type = Plant.Type.FOOD_SUPPLY
	add_child(food_supply_plant)
	await food_supply_plant.died
	lose()


func win():
	print("dubski")

func lose():
	print("L ski")


func _input(event: InputEvent):
	if not get_tree().paused:
		
		if Input.is_action_just_pressed("ui_cancel"):
			print("pausing game")
			get_tree().paused = true
			pause_menu.visible = true
			#toggle_game_paused.emit(true)



func _on_player_ui_bug_killed() -> void:
	bugs_killed+=1



func _on_test_open_shop_pressed() -> void:
	if shop.is_open:
		shop.close()
		upgrade_menu.visible = false
	else: 
		shop.open()
	
func _toggle_shop():
	print("opening shop")
	upgrade_menu.visible = true


func _on_pause_menu_unpausing_with_esc() -> void:
	get_tree().paused = false
	pause_menu.visible = false
