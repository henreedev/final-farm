extends Sprite2D
class_name Shop

var player_can_interact = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if player_can_interact and event.is_action_pressed("interact"):
		print("Player interacted with shop")


func _on_interact_area_body_entered(body: Node2D) -> void:
	if body is Player:
		print("Player can interact with shop")
		player_can_interact = true




func _on_interact_area_body_exited(body: Node2D) -> void:
	if body is Player:
		print("Player cannot interact with shop")
		player_can_interact = false
