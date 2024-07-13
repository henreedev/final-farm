extends Control
var currentSelectedItemIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ItemList.select(0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$FoodProgressBar.value += 1
	if $FoodProgressBar.value >= 100:
		$FoodProgressBar.value = 0
	process_scroll()

	

func process_scroll():
	var scroll_direction = Input.get_axis("scroll_down","scroll_up")
	if scroll_direction != 0:
		print(scroll_direction)
		currentSelectedItemIndex+= scroll_direction 
		currentSelectedItemIndex = fmod(currentSelectedItemIndex,5)
		if currentSelectedItemIndex <= -1:
			currentSelectedItemIndex += 5
			
	
	
	$ItemList.select(currentSelectedItemIndex)
	pass
