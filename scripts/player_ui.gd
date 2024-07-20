extends Control
class_name PlayerUI

var start_button_initial_pos : Vector2

var down_dist = 200


@onready var main : Main = get_tree().get_first_node_in_group("main")
@onready var player:Player = get_tree().get_first_node_in_group("player")
@onready var total_seeds_label : Label = $SeedBagIcon/TotalSeedsLabel
@onready var bug_kills_label : Label = $BugIcon/BugKillsLabel
@onready var start_button : Control = $Control2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_vars()
	connect_signals()

func _init_vars():
	start_button_initial_pos = start_button.position
	start_button.position.y += down_dist

func tween_start_button_down():
	var tween : Tween = create_tween().set_parallel()
	tween.tween_property(start_button, "position:y", \
		start_button_initial_pos.y + down_dist, 1.0).set_trans(Tween.TRANS_BACK)
	tween.tween_property(start_button, "modulate", Color(2,2,2,1), 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(start_button, "modulate", Color(1,1,1,0.5), 0.5).set_ease(Tween.EASE_OUT).set_delay(0.25)
	
	
	

func tween_start_button_up():
	start_button.modulate = Color(1,1,1,0.9)
	create_tween().tween_property(start_button, "position:y", \
		start_button_initial_pos.y, 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func connect_signals():
	player.total_seeds_changed.connect(update_total_seeds)
	player.bug_kills_changed.connect(update_bug_kills)

func update_total_seeds():
	total_seeds_label.text = str(player.total_seeds)

func update_bug_kills():
	bug_kills_label.text = str(player.bug_kills)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$FoodProgressBar.value = main.food_amount
