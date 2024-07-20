extends Control
class_name PlayerUI

@onready var main : Main = get_tree().get_first_node_in_group("main")
@onready var player:Player = get_tree().get_first_node_in_group("player")
@onready var total_seeds_label : Label = $SeedBagIcon/TotalSeedsLabel
@onready var bug_kills_label : Label = $BugIcon/BugKillsLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect_signals()

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
