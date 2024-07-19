extends Control
signal purchased_seed(type: Plant.Type)
signal player_upgrade(tempstring: String)
var isPurchased := [false]
@onready var main = get_tree().get_first_node_in_group("main")

@onready var seed_eggplant: TextureButton = $MarginContainer/TextureRect/ScrollContainer/HBoxContainer/seed_eggplant
@onready var seed_broccoli: TextureButton = $MarginContainer/TextureRect/ScrollContainer/HBoxContainer/seed_broccoli
@onready var seed_pepper: TextureButton = $MarginContainer/TextureRect/ScrollContainer/HBoxContainer/seed_pepper
@onready var scroll_container: ScrollContainer = $MarginContainer/TextureRect/ScrollContainer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#scroll_container.
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func purchase_upgrade(upgrade_name: String,price):
	pass



func _on_exit_pressed() -> void:
	visible = false
	pass # Replace with function body.

#region:Purchase seeds

func _on_seed_tomato_pressed() -> void:
	pass
	
func _on_seed_broccoli_pressed() -> void:
	if main.food_amount > 10:
		print("broc")
		main.food_amount -= 10
		purchased_seed.emit(Plant.Type.BROCCOLI)
		pass
	else:
		print("not enough to  broc")


func _on_seed_eggplant_pressed() -> void:
	if main.food_amount > 10:
		print("egg")
		main.food_amount -= 10
		purchased_seed.emit(Plant.Type.EGGPLANT)
		pass
	else:
		print("not enough to  egg")

#endregion:Purchase seeds

func _on_player_speed_pressed() -> void:
	player_upgrade.emit("speed")
	pass # Replace with function body.
	
