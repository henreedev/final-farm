extends Control
signal check_if_purchasable
var isPurchased := [false]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_button_button_down() -> void:
	purchase_upgrade("player_speed_1",10)

func purchase_upgrade(upgrade_name: String,price):
	check_if_purchasable.emit(upgrade_name, price)
	pass



func _on_exit_pressed() -> void:
	visible = false
	pass # Replace with function body.
