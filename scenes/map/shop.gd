extends AnimatedSprite2D
class_name Shop

var player_in_range = false
var is_open = true
var should_wave = true
var throws = []
var throwing = false
signal toggle_shop

var seed_bag_scene : PackedScene = preload("res://scenes/plants/seed_bag.tscn")
@onready var main : Main = get_tree().get_first_node_in_group("main")
@onready var wave_timer : Timer = $WaveTimer
@onready var interact_icon : AnimatedSprite2D = $InteractIcon

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if player_in_range and is_open and event.is_action_pressed("interact"):
		player_interact()

func player_interact():
	toggle_shop.emit()

func throw():
	animation = "throw" if is_open else "closed_throw"
	frame = 0
	play()
	throwing = true

func close():
	if throwing:
		await animation_changed
	animation = "close"
	play()
	is_open = false
	wave_timer.paused = true
	interact_icon.hide()
	interact_icon.stop()	

func open():
	if throwing:
		await animation_changed
	animation = "open"
	play()
	is_open = true
	wave_timer.paused = false
	if player_in_range:
			interact_icon.show()
			interact_icon.play()

func wave():
	animation = "wave"
	play()
	should_wave = false
	var new_dur = randf_range(5, 25)
	wave_timer.start(new_dur)

func _release_seed(type : Plant.Type):
	var seed_bag : SeedBag = seed_bag_scene.instantiate()
	seed_bag.thrown_to_player = true
	main.add_child(seed_bag)
	

func queue_throw(type : Plant.Type):
	throws.append(type)


func _on_interact_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true
		if is_open:
			interact_icon.show()
			interact_icon.play()

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		interact_icon.hide()
		interact_icon.stop()

func _on_animation_finished() -> void:
	match animation:
		"open", "close", "wave", "throw", "closed_throw":
			animation = "idle" if is_open else "closed_idle"
			play()


func _on_animation_looped() -> void:
	match animation:
		"idle":
			if not throws.is_empty():
				throw()
			elif should_wave:
				wave()
		"closed_idle":
			if not throws.is_empty():
				throw()

func _on_frame_changed() -> void:
	match animation:
		"throw", "closed_throw":
			if frame == 1:
				_release_seed(throws.pop_back())
			elif frame == 2:
				if not throws.is_empty(): throw()
				else: throwing = false



func _on_wave_timer_timeout() -> void:
	should_wave = true
