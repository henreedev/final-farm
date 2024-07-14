extends CharacterBody2D
class_name Player

#region: Globals

const TOP_BASE_OFFSET = Vector2i(0, -16)
const TOP_HIGHER_OFFSET = Vector2i(0, -17)
const HOE_ROOT_POS_TOP = Vector2(-5, -17)
const HOE_ROOT_POS_BOT = Vector2(-5, -11)
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

# Hoe vars
var hoe_angle_cone = 90.0
var hoe_duration = 0.5
var hoe_scene : PackedScene = preload("res://scenes/player/hoe.tscn")


@onready var bot : AnimatedSprite2D = $Bot
@onready var top : AnimatedSprite2D = $Top
#endregion: Globals

#region: Built-in functions
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

func start_throw():
	if not (holding_throw or swinging or throwing):
		holding_throw = true
		top.animation = "throw_windup"
		top.play()

func throw():
	if not swinging:
		throwing = true
		top.animation = "throw"
		top.play()

func swing():
	if holding_throw:
		holding_throw = false
	elif not (swinging or throwing):
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
	add_child(hoe)

#endregion: Player action functions




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
			print("throw windup finsihed")
			top.animation = "throw_hold"
			top.play()
		


