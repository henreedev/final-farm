extends Control
var currentSelectedItemIndex = 0
var num_of_seed_types = 4
signal bug_killed
@export var bugs_killed = 0
@onready var main : Main = get_tree().get_first_node_in_group("main")
@onready var player:Player = get_tree().get_first_node_in_group("player")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect_signals()
	$ItemList.select(0)
	_on_player_seed_count_changed()

func connect_signals():
	player.seed_count_changed.connect(_on_player_seed_count_changed)
	#player.seed_list_changed.connect(_on_player_seed_list_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$FoodProgressBar.value = main.food_amount
	process_scroll()

	

func process_scroll():
	var scroll_direction = 0
	if Input.is_action_just_released("scroll_up"): scroll_direction -=1
	if Input.is_action_just_released("scroll_down"): scroll_direction +=1
	
	if scroll_direction != 0:
		currentSelectedItemIndex+= scroll_direction 
		currentSelectedItemIndex = fmod(currentSelectedItemIndex,num_of_seed_types)
		if currentSelectedItemIndex <= -1:
			currentSelectedItemIndex += num_of_seed_types
	scroll_direction = 0
	
	
	$ItemList.select(currentSelectedItemIndex)
	pass


func TEST_set_eggplant_amount():
	$ItemList.set_item_text(0,str(player.seed_counts[0]))

func get_current_selected_item_index():
	return currentSelectedItemIndex

func _on_test_kill_increase_pressed() -> void:
	bug_killed.emit()
	bugs_killed+=1
	$TextureRect/Label.text = str("Bugs Killed:", bugs_killed)

func _on_player_seed_count_changed():
	var cur_pos = 0
	for seed_type in player.seed_counts.keys():
		print(player.seed_counts[seed_type])
		$ItemList.set_item_text(cur_pos,str(player.seed_counts[seed_type]))
		cur_pos+=1
		pass

func add_seed_type(seed:Plant.Type):
	for type in player.seed_counts:
		
		pass
	pass
	
func remove_seed_type():
	pass
	
func _on_player_seed_list_changed():
	
	pass
