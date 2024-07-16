extends AnimatedSprite2D
class_name Shop

var player_in_range = false
var is_open = true
var should_wave = true
var throws = []
var throwing = false
@onready var wave_timer : Timer = $WaveTimer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if player_in_range and is_open and event.is_action_pressed("interact"):
		player_interact()

func player_interact():
	print("Player interacted with shop (TODO)")

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

func open():
	if throwing:
		await animation_changed
	animation = "open"
	play()
	is_open = true
	wave_timer.paused = false

func wave():
	animation = "wave"
	play()
	should_wave = false
	var new_dur = randf_range(5, 25)
	wave_timer.start(new_dur)

func _release_seed(type : Plant.Type):
	print("throwing seed to player")
	# create seed object of given type
	# have it throw itself to player
	pass 

func queue_throw(type : Plant.Type):
	throws.append(type)


func _on_interact_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false


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