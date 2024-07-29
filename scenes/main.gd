extends Node2D
class_name Main
signal upgrade_purchased
signal wave_ended
signal wave_begun
signal info_toggled

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
@export var WINNING_FOOD_AMOUNT = 4
@export_range(0, 20, 1) var passive_seed_income_per_wave := 5

var bugs_killed = 0
var food_amount := 0

var show_info := false
var can_end_wave := false
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

var music_tween : Tween
var upgrade_menu_tween : Tween

@onready var food_holder = $Permanent/FoodHolder
@onready var player_ui: PlayerUI = $Permanent/CanvasLayer/Player_UI
@onready var upgrade_menu: UpgradeMenu = $Permanent/CanvasLayer/Upgrade_Menu
@onready var pause_menu: Control = $Permanent/CanvasLayer/pause_menu
@onready var player : Player = get_tree().get_first_node_in_group("player")
@onready var wave_timer : Timer = $Permanent/WaveTimer
@onready var wave_music : AudioStreamPlayer = $Permanent/WaveMusic
@onready var prewave_music : AudioStreamPlayer = $Permanent/PreWaveMusic

func _ready() -> void:
	get_tree().paused = false
	_calculate_thresholds()
	_initial_setup()
	begin_prewave()

func _initial_setup():
	player.adjust_bug_kills(0) 
	player_ui.food_bar.create_tween().tween_property(player_ui.food_bar, "position", Vector2(0, -3), 1.5).from(Vector2(0,-100)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	player_ui.food_bar.max_value = WINNING_FOOD_AMOUNT

func begin_prewave():
	if state == State.GAME_OVER: return
	state = State.PREWAVE
	can_end_wave = false
	_switch_music(false)
	_delete_spawners()
	if not waves_set_up:
		_setup_waves()
	_select_wave()
	player.adjust_total_seeds(passive_seed_income_per_wave)
	_pause_plants(true)
	_create_spawners()
	_toggle_dir_indicator(true)
	_toggle_start_button(true)
	_toggle_shop_open(true)
	# TODO show wave info
	await wave_begun
	begin_wave()

func begin_wave():
	if state == State.GAME_OVER: return
	state = State.WAVE
	_switch_music(true)
	_start_wave_timer(cur_wave.duration)
	_begin_spawners()
	_pause_plants(false)
	_toggle_dir_indicator(false)
	_toggle_start_button(false)
	_toggle_shop_open(false)
	await wave_ended
	begin_prewave()

func _switch_music(is_wave : bool):
	if music_tween:
		music_tween.kill()
	music_tween = create_tween().set_parallel()
	if is_wave:
		wave_music.play()
		music_tween.tween_property(wave_music, "volume_db", -17.0, 1.0)
		music_tween.tween_property(prewave_music, "volume_db", -60.0, 1.0)
		music_tween.tween_callback(prewave_music.stop).set_delay(1.0)
	else:
		prewave_music.play()
		music_tween.tween_property(prewave_music, "volume_db", -18.0, 1.0)
		music_tween.tween_property(wave_music, "volume_db", -60.0, 1.0)
		music_tween.tween_callback(wave_music.stop).set_delay(1.0)

func _toggle_shop_open(open : bool):
	await get_tree().create_timer(0.15).timeout
	
	if not shop:
		shop = get_tree().get_first_node_in_group("shop")
	if open:
		if shop: shop.open()
	else:
		if shop: shop.close()

func _toggle_start_button(on : bool):
	if on:
		player_ui.tween_start_button_up()
	else:
		player_ui.tween_start_button_down()

func _start_wave_timer(duration : float):
	wave_timer.start(duration)

func trigger_wave_begun():
	upgrade_menu.close()
	wave_begun.emit()

func _toggle_dir_indicator(on : bool):
	if on:
		player.wave_indicator.set_spawners(spawners)
		var tween : Tween = create_tween()
		tween.tween_property(player.wave_indicator, "modulate", Color(1, 1, 1, 1), 3.0).set_trans(Tween.TRANS_CUBIC)
	else:
		var tween : Tween = create_tween()
		tween.tween_property(player.wave_indicator, "modulate", Color(1, 1, 1, 0), 3.0).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(player.wave_indicator.set_spawners)

func _begin_spawners():
	for spawner : Spawner in spawners:
		spawner.begin_spawning()

func _create_spawners():
	# Create wave groups of a fraction of the size to give to each spawner
	var num_spawners = int(quarter) + 1
	var wave_delegation : Array[WaveGroup] = []
	var wave_delegation_with_leftover : Array[WaveGroup] = [] # make one with the leftover from int-division
	var seen_types := {}
	for type : Insect.Type in Insect.Type.values():
		seen_types[type] = false
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
			if not Utils.fly_mutated:
				fly_sightings_until_mutation -= 1
				if fly_sightings_until_mutation < 0:
					Utils.fly_mutated = true


func _pick_random_spawner_pos(index : int, total : int):
	var angle_width = TAU / total
	var start = index * angle_width
	var end = (index + 1) * angle_width
	var rand_angle = randf_range(start, end)
	
	const ISOMETRIC_ADJUST = 0.5
	const SPAWNER_DIST_RADIUS = 16 * 25
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

func receive_food():
	food_amount += 1
	player.adjust_total_seeds(1)
	player_ui.food_bar.value = food_amount
	_check_food_thresholds()
	if food_holder.get_child_count() > 20:
		food_holder.get_child(0).queue_free()
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
	if state != State.GAME_OVER:
		state = State.GAME_OVER
		player.target_zoom_override = Vector2(4.0, 4.0)
		player_ui.winlose_label.text = "You won!!!"
		create_tween().tween_property(food_holder, "modulate", Color(2,2,2,1), 1.0).set_trans(Tween.TRANS_CUBIC)
		create_tween().tween_property(food_holder, "position", Vector2(0, -600), 3.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

func lose():
	if state != State.GAME_OVER:
		state = State.GAME_OVER
		player.target_zoom_override = Vector2(4.0, 4.0)
		create_tween().tween_property(food_holder, "modulate", Color(.5,.5,.5,0), 5.0).set_trans(Tween.TRANS_CUBIC)
		player_ui.winlose_label.text = "You lost..."


func _input(_event: InputEvent):
	if not get_tree().paused:
		if Input.is_action_just_pressed("escape_menu"):
			if not upgrade_menu.is_open:
				get_tree().paused = true
				pause_menu.visible = true
		if _event.is_action_pressed("show_info"):
			show_info = not show_info
			info_toggled.emit()

func on_insect_died():
	await get_tree().create_timer(0.1).timeout
	if can_end_wave and get_tree().get_node_count_in_group("insect") == 0:
		wave_ended.emit()


func _on_player_ui_bug_killed() -> void:
	bugs_killed+=1

func _on_test_open_shop_pressed() -> void:
	if shop.is_open:
		shop.close()
		upgrade_menu.visible = false
	else: 
		shop.open()
	

func _on_pause_menu_unpausing_with_esc() -> void:
	get_tree().paused = false
	pause_menu.visible = false


func _on_wave_timer_timeout():
	can_end_wave = true
