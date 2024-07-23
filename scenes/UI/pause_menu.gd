extends Control
signal unpausing_with_esc
@onready var main = get_tree().get_first_node_in_group("main")
@onready var options_menu: Control = $MarginContainer/options_menu
@onready var main_options: VBoxContainer = $MarginContainer/VBoxContainer
@onready var upgrade_menu : UpgradeMenu = get_tree().get_first_node_in_group("upgrade_menu")
@onready var continue_button = $MarginContainer/VBoxContainer/Continue
@onready var restart_button = $MarginContainer/VBoxContainer/Restart
@onready var exit_button = $MarginContainer/VBoxContainer/Exit


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

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_main_toggle_game_paused(is_paused: bool):
	visible = true

func _on_options_menu_exit_options() -> void:
	options_menu.visible = false
	main_options.visible = true


func _on_restart_pressed():
	continue_button.text = ""
	$MarginContainer/VBoxContainer/Restart.text = "Restarting..."
	$MarginContainer/VBoxContainer/Exit.text = ""
	var timer : Timer = Timer.new()
	add_child(timer)
	timer.start(0.2)
	await timer.timeout
	Utils.restart()
	get_tree().reload_current_scene()
