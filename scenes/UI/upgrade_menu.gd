extends Control
signal check_if_purchasable
signal purchased_seed(type: Plant.Type)
var isPurchased := [false]
@onready var main = get_tree().get_first_node_in_group("main")

@onready var player_speed: Button = $"MarginContainer/TabContainer/Player Upgrades/ScrollContainer/player_speed"
@onready var seed_tomato: Button = $MarginContainer/TabContainer/Seeds/TextureRect/ScrollContainer/HBoxContainer/seed_tomato
@onready var seed_eggplant: Button = $MarginContainer/TabContainer/Seeds/TextureRect/ScrollContainer/HBoxContainer/seed_eggplant



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func purchase_upgrade(upgrade_name: String,price):
	pass



func _on_exit_pressed() -> void:
	visible = false
	pass # Replace with function body.


func _on_seed_tomato_pressed() -> void:
	
	pass # Replace with function body.


func _on_seed_eggplant_pressed() -> void:
	if main.food_amount > 10:
		print("egg")
		main.food_amount -= 10
		purchased_seed.emit(Plant.Type.EGGPLANT)
		pass
	else:
		print("not enough to  egg")
	pass # Replace with function body.


func _on_player_speed_pressed() -> void:
	pass # Replace with function body.
