extends CharacterBody2D
class_name Player

#region: Globals

const TOP_BASE_OFFSET = Vector2i(0, -16)
const TOP_HIGHER_OFFSET = Vector2i(0, -17)
const HOE_ROOT_POS_TOP = Vector2(-5, -17)
const HOE_ROOT_POS_BOT = Vector2(-5, -11)
const IGNORE_SWING_AFTER_CANCEL_DUR = 0.4
const ISOMETRIC_MOVEMENT_ADJUST = 0.5
const SPEED = 70.0

# Animation vars
var moving := false
var moving_vert := false
var moving_hoz := false
var going_left := false
var going_up := false
var mouse_left := false
var mouse_up := false
var locked_swing_animation := false

#State vars
var swinging = false
var throwing = false
var holding_throw = false
# Tracks how many of each seed you have
var seed_counts = {} # TODO populate with Seed.Type : 0

# Swing vars
var ignore_swing := false

# Hoe vars
var hoe_angle_cone = 180.0
var hoe_duration = 1.0
var hoe_scene : PackedScene = preload("res://scenes/player/hoe.tscn")

# Throw vars
var throw_tween : Tween 
var throw_zoomout_ratio = 0.7
var throw_zoomout_time = 1.5
var initial_zoom : Vector2
var target_zoom : Vector2

@onready var bot : AnimatedSprite2D = $S/Bot
@onready var top : AnimatedSprite2D = $S/Top
@onready var cam : Camera2D = $Camera2D
@onready var throw_zoom_timer : Timer = $ThrowZoomTimer
@onready var ignore_swing_timer : Timer = $IgnoreSwingTimer
var shop : Shop # onready does not work because shop is instantiated in a TileMapLayer after _ready

@onready var upgrade_menu = get_tree().get_first_node_in_group("upgrade_menu")

#endregion: Globals

#region: Built-in functions
func _ready() -> void:
	_init_vars()
	
	#testing direct connection from upgrade menu to player
	upgrade_menu.purchased_seed_eggplant.connect(test_connection)
	
func test_connection():
	print("yay")
	pass
	

func _init_vars() -> void:
	initial_zoom = cam.zoom
	target_zoom = initial_zoom
	await get_tree().create_timer(0.01).timeout
	shop = get_tree().get_first_node_in_group("shop")

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("Left","Right","Up","Down")
	if input_direction.y and input_direction.x: 
		input_direction.y *= ISOMETRIC_MOVEMENT_ADJUST
		input_direction = input_direction.normalized()
	elif input_direction.y:
		input_direction.y *= 0.83
	velocity = input_direction * SPEED
	move_and_slide()
	_act_on_input()
	_pick_animations(input_direction)

func _process(delta: float) -> void:
	_calc_throw_zoom(delta)
	_calc_camera_zoom(delta)

#endregion: Built-in functions

#region: Animation functions
func _pick_animations(input_dir : Vector2):
	_calc_animation_vars(input_dir)
	_pick_legs_animation()
	_pick_arms_animation()

func _calc_animation_vars(input_dir : Vector2):
	moving = not input_dir.is_zero_approx()
	moving_hoz = input_dir.x != 0
	moving_vert = input_dir.y != 0
	going_left = (input_dir.x < 0) if moving_hoz else going_left
	going_up = (input_dir.y < 0) if moving_vert else going_up
	if holding_throw or swinging:
		var mouse_rel_pos = get_local_mouse_position()
		mouse_left = mouse_rel_pos.x < 0
		mouse_up = mouse_rel_pos.y < 0

func _pick_legs_animation():
	if moving:
		if moving_vert and not moving_hoz:
			bot.animation = "run_up"
		else:
			bot.animation = "run"
	else:
		bot.animation = "idle"
	bot.flip_h = not going_left
	bot.play()

func _pick_arms_animation(): 
	if holding_throw or throwing or swinging:
		if swinging:
			pass
		elif holding_throw or throwing: 
			top.flip_h = not mouse_left
	else:
		if moving:
			top.animation = "run"
		else:
			top.animation = "idle"
		top.flip_h = not going_left
		top.play()
#endregion: Animation functions

#region: Player action functions

func _act_on_input():
	if Input.is_action_pressed("swing"):
		swing()
	elif Input.is_action_pressed("throw"):
		start_throw()
	elif holding_throw:
		throw()
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	if Input.is_action_just_pressed("purchase_seed"):
		if not shop: shop = get_tree().get_first_node_in_group("shop")
		shop.queue_throw(Plant.Type.EGGPLANT)
	if Input.is_action_just_pressed("interact"):
		if shop.is_open:
			shop.close()
		else:
			shop.open()

func start_throw():
	if not (holding_throw or swinging or throwing or ignore_swing):
		holding_throw = true
		top.animation = "throw_windup"
		top.play()
		throw_zoom_timer.start(throw_zoomout_time)

func throw():
	if not swinging:
		throwing = true
		top.animation = "throw"
		top.play()

func _calc_throw_zoom(delta):
	if holding_throw or throwing:
		var total = throw_zoomout_time
		var time_elapsed = total - throw_zoom_timer.time_left if not throw_zoom_timer.is_stopped() else throw_zoomout_time
		const DELAY_RATIO = 0.38
		var ratio = clampf(time_elapsed / total - DELAY_RATIO, 0, 1) / (1 - DELAY_RATIO) 
		target_zoom = lerp(initial_zoom, initial_zoom * throw_zoomout_ratio, ratio)
	else: 
		const STR = 2.0
		target_zoom = target_zoom.move_toward(initial_zoom, STR * delta)

func _calc_camera_zoom(delta):
	const STR = 3.0
	cam.zoom = lerp(cam.zoom, target_zoom, STR * delta)

func swing():
	if holding_throw:
		holding_throw = false
		ignore_swing_timer.start(IGNORE_SWING_AFTER_CANCEL_DUR)
		ignore_swing = true
	elif not (swinging or throwing or ignore_swing):
		swinging = true
		_calc_animation_vars(Vector2(0,0))
		top.animation = "swing_top" if mouse_up else "swing"
		top.flip_h = not mouse_left
		top.sprite_frames.set_animation_speed(top.animation, 1.0 / hoe_duration)
		top.play()
		_create_hoe()

func _create_hoe():
	var root_pos = HOE_ROOT_POS_TOP if mouse_up else HOE_ROOT_POS_BOT
	root_pos.x *= -1 if not mouse_left else 1 
	var angle = (get_local_mouse_position() - root_pos).angle()
	var hoe : Hoe = hoe_scene.instantiate()
	hoe.position = root_pos
	hoe.rotation = angle
	hoe.angle_cone = hoe_angle_cone
	hoe.duration = hoe_duration
	$S.add_child(hoe)

#endregion: Player action functions



#region: Helper functions



#endregion: Helper functions



func _on_bot_frame_changed() -> void:
	if bot.frame == 1 or bot.frame == 2:
		top.offset = TOP_HIGHER_OFFSET
	else:
		top.offset = TOP_BASE_OFFSET


func _on_top_animation_finished() -> void:
	match top.animation:
		"swing", "swing_top":
			swinging = false
			locked_swing_animation = false
		"throw":
			holding_throw = false
			throwing = false
		"throw_windup":
			top.animation = "throw_hold"
			top.play()
		


func _on_ignore_swing_timer_timeout() -> void:
	ignore_swing = false
