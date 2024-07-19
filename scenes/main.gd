extends Node2D
class_name Main
signal upgrade_purchased
signal wave_ended
signal wave_begun

enum State {PREWAVE, WAVE, GAME_OVER}

enum Quarter {Quarter1, Quarter2, Quarter3, Quarter4}
enum Third {Third1, Third2, Third3}

var state : State = State.PREWAVE
var quarter : Quarter = Quarter.Quarter1
var third : Third = Third.Third1


const MAX_FOOD_HEIGHT = Vector2(0, -24)

@export_group("Waves")
@export_subgroup("Quarter 1")
@export var quarter_1_wave_table_1 : Array[Wave]
@export var quarter_1_wave_table_2 : Array[Wave]
@export var quarter_1_wave_table_3 : Array[Wave]
@export_subgroup("Quarter 2")
@export var quarter_2_wave_table_1 : Array[Wave]
@export var quarter_2_wave_table_2 : Array[Wave]
@export var quarter_2_wave_table_3 : Array[Wave]
@export_subgroup("Quarter 3")
@export var quarter_3_wave_table_1 : Array[Wave]
@export var quarter_3_wave_table_2 : Array[Wave]
@export var quarter_3_wave_table_3 : Array[Wave]
@export_subgroup("Quarter 4")
@export var quarter_4_wave_table_1 : Array[Wave]
@export var quarter_4_wave_table_2 : Array[Wave]
@export var quarter_4_wave_table_3 : Array[Wave]
@export_subgroup("")
@export_group("Quarter Weights")
# Quarter weights relatively proportion how much food is required to progress through each quarter
@export_range(0.1, 10.0, 0.1) var quarter_1_weight := 1.0
@export_range(0.1, 10.0, 0.1) var quarter_2_weight := 1.0
@export_range(0.1, 10.0, 0.1) var quarter_3_weight := 1.0
@export_range(0.1, 10.0, 0.1) var quarter_4_weight := 1.0
# Given three thirds within a quarter, the middle third stays the same length, 
# whereas the sooner third loses this percent of food required and the later third gains this percent
@export_range(0.0, .49, 0.01) var third_length_shift_ratio := .05
@export_group("Mutation Rates")
@export var fly_sightings_until_mutation := 1
@export_group("Gameplay Values")
@export var WINNING_FOOD_AMOUNT = 1000
@export var passive_seed_income_per_wave := 5

var bugs_killed = 0
var food_amount := 0

var waves_set_up := false
var cur_wave : Wave
var cur_wave_table : Array[Wave]
var cur_wave_table_options : Array[int]

var first_threshold : float
var second_threshold : float
var third_threshold : float

var quarter_1_threshold_1 : float
var quarter_1_threshold_2 : float
var quarter_2_threshold_1 : float
var quarter_2_threshold_2 : float
var quarter_3_threshold_1 : float
var quarter_3_threshold_2 : float
var quarter_4_threshold_1 : float
var quarter_4_threshold_2 : float

var food_supply_height = Vector2(0,0)
var food_supply_plant : Plant 
var plants_paused := false
var plant_scene : PackedScene = preload("res://scenes/plants/plant.tscn")
var spawner_scene : PackedScene = preload("res://assets/image/map/spawner.tscn")
var spawners : Array[Spawner] = []
var shop : Shop
#var has_init_shop = false

@onready var food_holder = $FoodHolder
@onready var player_ui: Control = $CanvasLayer/Player_UI
@onready var upgrade_menu: Control = $CanvasLayer/Upgrade_Menu
@onready var pause_menu: Control = $CanvasLayer/pause_menu
@onready var player : Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	_calculate_thresholds()
	begin_prewave()
	_connect_signals()

func begin_prewave():
	if state == State.GAME_OVER: return
	state = State.PREWAVE
	_delete_spawners()
	if not waves_set_up:
		_setup_waves()
	_select_wave()
	_pause_plants(true)
	_create_spawners()
	_toggle_dir_indicator(true)
	_toggle_shop_open(true)
	# TODO show wave info
	await wave_begun
	begin_wave()

func begin_wave():
	if state == State.GAME_OVER: return
	state = State.WAVE
	_begin_spawners()
	_pause_plants(false)
	_toggle_dir_indicator(false)
	await wave_ended
	begin_prewave()

func _toggle_shop_open(open : bool):
	await get_tree().create_timer(0.05).timeout
	if not shop:
		shop = get_tree().get_first_node_in_group("shop")
	if open:
		shop.open()
	else:
		shop.close()

func trigger_wave_begun():
	wave_begun.emit()

func _toggle_dir_indicator(on : bool):
	if on:
		player.wave_indicator.set_spawners(spawners)
	else:
		player.wave_indicator.set_spawners()

func _begin_spawners():
	for spawner : Spawner in spawners:
		spawner.begin_spawning()

func _create_spawners():
	# Create wave groups of a fraction of the size to give to each spawner
	var num_spawners = int(quarter) + 1
	var wave_delegation : Array[WaveGroup] = []
	var wave_delegation_with_leftover : Array[WaveGroup] = [] # make one with the leftover from int-division
	var seen_types := {}
	for wave_group : WaveGroup in cur_wave.wave_groups:
		var split_wave_group = WaveGroup.new()
		split_wave_group.type = wave_group.type
		if not seen_types or not seen_types[wave_group.type]:
			_increment_mutation(wave_group.type)
			seen_types[wave_group.type] = true 
		split_wave_group.count = wave_group.count / num_spawners
		split_wave_group.spawn_time = wave_group.spawn_time
		split_wave_group.streams = wave_group.streams
		split_wave_group.stream_duration = wave_group.stream_duration
		wave_delegation.append(split_wave_group)
		# check for leftover
		var leftover = wave_group.count % num_spawners
		if leftover:
			var split_wave_group_with_leftover = WaveGroup.new()
			split_wave_group_with_leftover.type = split_wave_group.type
			split_wave_group_with_leftover.count = split_wave_group.count
			split_wave_group_with_leftover.spawn_time = split_wave_group.spawn_time
			split_wave_group_with_leftover.streams = split_wave_group.streams
			split_wave_group_with_leftover.stream_duration = split_wave_group.stream_duration
			wave_delegation_with_leftover.append(split_wave_group_with_leftover)
		else:
			wave_delegation_with_leftover.append(split_wave_group)
	# Give spawners the wave groups; first spawner gets leftovers :yum:
	var first = true
	for i in range(num_spawners):
		var new_spawner : Spawner = spawner_scene.instantiate()
		if first:
			new_spawner.insects_to_spawn = wave_delegation_with_leftover
			first = false
		else:
			new_spawner.insects_to_spawn = wave_delegation
		new_spawner.position = _pick_random_spawner_pos(i, num_spawners)
		spawners.append(new_spawner)
		add_child(new_spawner)

func _delete_spawners():
	if len(spawners) > 0:
		for spawner in spawners:
			spawner.queue_free()
	spawners.clear()

func _increment_mutation(type : Insect.Type):
	match type:
		Insect.Type.FLY:
			if not Insect.fly_mutated:
				fly_sightings_until_mutation -= 1
				if fly_sightings_until_mutation < 0:
					Insect.fly_mutated = true


func _pick_random_spawner_pos(index : int, total : int):
	var angle_width = TAU / total
	var start = index * angle_width
	var end = (index + 1) * angle_width
	var rand_angle = randf_range(start, end)
	
	const ISOMETRIC_ADJUST = 0.5
	const SPAWNER_DIST_RADIUS = 16 * 30
	var spawner_pos = Vector2.from_angle(rand_angle) * SPAWNER_DIST_RADIUS
	spawner_pos.y *= ISOMETRIC_ADJUST
	return spawner_pos


func _pause_plants(paused : bool):
	plants_paused = paused
	for plant : Plant in get_tree().get_nodes_in_group("plant"):
		plant.paused = paused

func _setup_waves():
	waves_set_up = true
	match quarter:
		Quarter.Quarter1:
			match third:
				Third.Third1:
					cur_wave_table = quarter_1_wave_table_1
				Third.Third2:
					cur_wave_table = quarter_1_wave_table_2
				Third.Third3:
					cur_wave_table = quarter_1_wave_table_3
		Quarter.Quarter2:
			match third:
				Third.Third1:
					cur_wave_table = quarter_2_wave_table_1
				Third.Third2:
					cur_wave_table = quarter_2_wave_table_2
				Third.Third3:
					cur_wave_table = quarter_2_wave_table_3
		Quarter.Quarter3:
			match third:
				Third.Third1:
					cur_wave_table = quarter_3_wave_table_1
				Third.Third2:
					cur_wave_table = quarter_3_wave_table_2
				Third.Third3:
					cur_wave_table = quarter_3_wave_table_3
		Quarter.Quarter4:
			match third:
				Third.Third1:
					cur_wave_table = quarter_4_wave_table_1
				Third.Third2:
					cur_wave_table = quarter_4_wave_table_2
				Third.Third3:
					cur_wave_table = quarter_4_wave_table_3

func _select_wave():
	if len(cur_wave_table_options) == 0:
		for i in range(len(cur_wave_table)):
			cur_wave_table_options.append(i)
	var rand_index = randi_range(0, len(cur_wave_table_options) - 1)
	cur_wave_table_options.remove_at(rand_index)
	cur_wave = cur_wave_table[rand_index]

func switch(new_quarter : Quarter, new_third : Third):
	if new_quarter != quarter or new_third != third:
		waves_set_up = false
		if new_quarter != quarter:
			# Do stuff on quarter change
			pass # TODO add boss wave here
		elif new_third != third:
			# Do stuff on third change
			pass
	quarter = new_quarter
	third = new_third

func _calculate_thresholds():
	# Calculate thresholds for quarters
	var sum = quarter_1_weight + quarter_2_weight + quarter_3_weight + quarter_4_weight
	var q1_ratio = quarter_1_weight / sum
	var q2_ratio = quarter_2_weight / sum
	var q3_ratio = quarter_3_weight / sum
	var q4_ratio = quarter_4_weight / sum
	var q1_amount = WINNING_FOOD_AMOUNT * q1_ratio
	var q2_amount = WINNING_FOOD_AMOUNT * q2_ratio
	var q3_amount = WINNING_FOOD_AMOUNT * q3_ratio
	var q4_amount = WINNING_FOOD_AMOUNT * q4_ratio
	first_threshold = q1_amount
	second_threshold = q1_amount + q2_amount
	third_threshold = q1_amount + q2_amount + q3_amount
	
	# Calculate thresholds for thirds
	var first_third_factor = (1 - third_length_shift_ratio)
	# Quarter 1
	var q1_middle_third_amount = q1_amount / 3 # imprecise but whatever
	var q1_first_third_amount = q1_middle_third_amount * first_third_factor
	quarter_1_threshold_1 = 0 + q1_first_third_amount
	quarter_1_threshold_2 = 0 + q1_first_third_amount + q1_middle_third_amount
	# Quarter 2
	var q2_middle_third_amount = q2_amount / 3 
	var q2_first_third_amount = q2_middle_third_amount * first_third_factor
	quarter_2_threshold_1 = first_threshold + q2_first_third_amount
	quarter_2_threshold_2 = first_threshold + q2_first_third_amount + q2_middle_third_amount
	# Quarter 3
	var q3_middle_third_amount = q3_amount / 3 
	var q3_first_third_amount = q3_middle_third_amount * first_third_factor
	quarter_3_threshold_1 = second_threshold + q3_first_third_amount
	quarter_3_threshold_2 = second_threshold + q3_first_third_amount + q3_middle_third_amount
	# Quarter 4
	var q4_middle_third_amount = q4_amount / 3 
	var q4_first_third_amount = q4_middle_third_amount * first_third_factor
	quarter_4_threshold_1 = third_threshold + q4_first_third_amount
	quarter_4_threshold_2 = third_threshold + q4_first_third_amount + q4_middle_third_amount
	print(quarter_1_threshold_1)
	print(quarter_1_threshold_2)
	print(first_threshold)
	print(quarter_2_threshold_1)
	print(quarter_2_threshold_2)
	print(second_threshold)
	print(quarter_3_threshold_1)
	print(quarter_3_threshold_2)
	print(third_threshold)
	print(quarter_4_threshold_1)
	print(quarter_4_threshold_2)


func _connect_signals():
	await get_tree().create_timer(0.1).timeout
	upgrade_menu.check_if_purchasable.connect(_on_upgrade_menu_check_if_purchasable)
	shop.toggle_shop.connect(_toggle_shop)

func receive_food():
	food_amount += 1
	_check_food_thresholds()
	var ratio = float(food_amount) / float(WINNING_FOOD_AMOUNT)
	food_supply_height = lerp(Vector2(0,0), MAX_FOOD_HEIGHT, ratio)
	food_supply_height.x = int(food_supply_height.x)
	food_supply_height.y = int(food_supply_height.y)
	if not food_supply_plant:
		create_food_supply_plant()
	if food_amount >= WINNING_FOOD_AMOUNT:
		win()

func _check_food_thresholds():
	match quarter:
		Quarter.Quarter1:
			match third:
				Third.Third1:
					if food_amount >= quarter_1_threshold_1: 
						switch(Quarter.Quarter1, Third.Third2)
				Third.Third2:
					if food_amount >= quarter_1_threshold_2: 
						switch(Quarter.Quarter1, Third.Third3)
				Third.Third3:
					if food_amount >= first_threshold: 
						switch(Quarter.Quarter2, Third.Third1)
		Quarter.Quarter2:
			match third:
				Third.Third1:
					if food_amount >= quarter_2_threshold_1: 
						switch(Quarter.Quarter2, Third.Third2)
				Third.Third2:
					if food_amount >= quarter_2_threshold_2: 
						switch(Quarter.Quarter2, Third.Third3)
				Third.Third3:
					if food_amount >= second_threshold: 
						switch(Quarter.Quarter3, Third.Third1)
		Quarter.Quarter3:
			match third:
				Third.Third1:
					if food_amount >= quarter_3_threshold_1: 
						switch(Quarter.Quarter3, Third.Third2)
				Third.Third2:
					if food_amount >= quarter_3_threshold_2: 
						switch(Quarter.Quarter3, Third.Third3)
				Third.Third3:
					if food_amount >= third_threshold: 
						switch(Quarter.Quarter4, Third.Third1)
		Quarter.Quarter4:
			match third:
				Third.Third1:
					if food_amount >= quarter_4_threshold_1: 
						switch(Quarter.Quarter4, Third.Third2)
				Third.Third2:
					if food_amount >= quarter_4_threshold_2: 
						switch(Quarter.Quarter4, Third.Third3)
				Third.Third3:
					if food_amount >= WINNING_FOOD_AMOUNT: 
						win()
func create_food_supply_plant():
	food_supply_plant = plant_scene.instantiate()
	food_supply_plant.type = Plant.Type.FOOD_SUPPLY
	add_child(food_supply_plant)
	await food_supply_plant.died
	lose()


func win():
	state = State.GAME_OVER
	print("dubski")

func lose():
	state = State.GAME_OVER
	print("L ski")


func _input(_event: InputEvent):
	if not get_tree().paused:
		if Input.is_action_just_pressed("ui_cancel"):
			print("pausing game")
			get_tree().paused = true
			pause_menu.visible = true

func on_insect_died():
	await get_tree().create_timer(0.1).timeout
	if get_tree().get_node_count_in_group("insect") == 0:
		wave_ended.emit()


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
