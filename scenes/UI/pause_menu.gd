extends Control
signal unpausing_with_esc
@onready var main = get_tree().get_first_node_in_group("main")
@onready var options_menu: Control = $MarginContainer/options_menu
@onready var main_options: VBoxContainer = $MarginContainer/VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect_signals()
	pass # Replace with function body.

func connect_signals():
	#main.toggle_game_paused.connect(_on_main_toggle_game_paused)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent):	
	if Input.is_action_just_pressed("ui_cancel"):
		await get_tree().create_timer(0.01).timeout
		unpausing_with_esc.emit()


func _on_continue_pressed() -> void:
	hide()
	get_tree().paused = false


func _on_options_pressed() -> void:
	options_menu.visible = true
	main_options.visible = false
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_main_toggle_game_paused(is_paused: bool):
	visible = true
	pass




func _on_options_menu_exit_options() -> void:
	options_menu.visible = false
	main_options.visible = true
	pass # Replace with function body.
