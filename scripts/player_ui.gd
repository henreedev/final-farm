extends Control
var currentSelectedItemIndex = 0
signal bug_killed
@export var bugs_killed = 0
@onready var main : Main = get_tree().get_first_node_in_group("main")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ItemList.select(0)


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
		currentSelectedItemIndex = fmod(currentSelectedItemIndex,5)
		if currentSelectedItemIndex <= -1:
			currentSelectedItemIndex += 5
	scroll_direction = 0
	
	
	$ItemList.select(currentSelectedItemIndex)
	pass



func _on_test_kill_increase_pressed() -> void:
	bug_killed.emit()
	bugs_killed+=1
	$TextureRect/Label.text = str("Bugs Killed:", bugs_killed)

	
