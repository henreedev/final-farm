extends Area2D
class_name Projectile

#region: Globals
var type : Plant.Type
var insect_type : Insect.Type

var damage : int
var speed : float
var radius : float
var lifespan := 10.0

var dir : Vector2
var allied := true
var should_fire := true
var deleting := false
var has_shadow := true
var has_offset := true
var delete_on_damage := true
var delete_on_finish := true
var offset := Vector2(0, -8)
var disable_collision_after_frames := -1
var fires_to_target := false
var chase_progress := -1.0
var chase_duration : float
var target : Node2D
var target_last_pos : Vector2
var start_pos : Vector2
signal chase_complete
@onready var holder = $Holder
@onready var shadow = $Shadow
@onready var asprite : AnimatedSprite2D = $Holder/AnimatedSprite2D
@onready var circle_hitbox : CollisionShape2D = $Hitbox
@onready var tomato_hitbox : CollisionPolygon2D = $TomatoFireHitbox
@onready var potato_hitbox : CollisionPolygon2D = $PotatoExplosionHitbox
@onready var watermelon_hitbox : CollisionPolygon2D = $WatermelonExplosionHitbox

#endregion: Globals

#region: Universal functions
# Called when the node enters the scene tree for the first time.
func _ready():
	_make_hitboxes_unique()
	pick_values_on_type()
	if should_fire:
		_fire()
	reset_physics_interpolation()
	modulate = Color(1,1,1,1)
	asprite.position = position + offset
	asprite.rotation = rotation
	shadow.global_rotation = 0

func _make_hitboxes_unique():
	circle_hitbox.shape = CircleShape2D.new()

func pick_values_on_type():
	if allied:
		asprite.animation = Utils.get_plant_string(type) 
	else:
		asprite.animation = Utils.get_insect_string(insect_type)
	circle_hitbox.shape.radius = radius
	start_pos = position
	if target:
		target_last_pos = target.position
	else: target_last_pos = position
	match type:
		Plant.Type.TOMATO:
			disable_collision_after_frames = 4
			delete_on_damage = false
			tomato_hitbox.disabled = false
			circle_hitbox.disabled = true
			should_fire = false
			has_shadow = false
			offset = Vector2(0, 0)
		Plant.Type.POTATO:
			disable_collision_after_frames = 4
			delete_on_damage = false
			potato_hitbox.disabled = false
			circle_hitbox.disabled = true
			should_fire = false
			has_shadow = false
			offset = Vector2(0, 0)
			rotation = 0
		Plant.Type.PEPPER:
			chase_duration = 0.75
			has_shadow = false
			fires_to_target = true
			delete_on_damage = false
		Plant.Type.WATERMELON:
			delete_on_damage = false
			circle_hitbox.disabled = true
			has_shadow = false
			fires_to_target = true
			chase_duration = 1.5
			disable_collision_after_frames = 3
	if not has_shadow: shadow.hide()
	asprite.play()
func _fire():
	var tween : Tween = create_tween()
	if fires_to_target:
		tween.tween_property(self, "chase_progress", 1.0, chase_duration).from(0.0)
		tween.tween_callback(_chase_complete)
	else:
		var final_pos := position + dir * speed * lifespan 
		tween.tween_property(self, "position", final_pos, lifespan)
		tween.tween_callback(delete)

func _chase_complete():
	match type:
		Plant.Type.PEPPER:
			if target:
				attach_to_node(target)
			else:
				delete()
		Plant.Type.WATERMELON:
			asprite.animation = "watermelon_explosion"
			asprite.play()
			watermelon_hitbox.disabled = false
			rotation = 0

func delete():
	deleting = true
	# Add deletion VFX here
	queue_free()

func _physics_process(delta):
	if chase_progress < 1 and chase_progress >= 0:
		if target and is_instance_valid(target):
			position = Utils.calc_point_on_arc_between(start_pos, target.position, chase_progress)
			target_last_pos = target.position
		else: 
			position = Utils.calc_point_on_arc_between(start_pos, target_last_pos, chase_progress)
			if type == Plant.Type.PEPPER:
				circle_hitbox.disabled = false
	asprite.position = global_position + offset
	asprite.rotation = rotation
	shadow.global_rotation = 0
#endregion: Universal functions

#region: Pepper functions
func attach_to_node(node):
	if node == null or not is_instance_valid(node):
		delete()
	else:
		z_index = 2
		reparent.call_deferred(node)
		set_deferred("global_position", node.position)
		var tween : Tween = node.create_tween().set_loops()
		tween.tween_callback(node.take_damage.bind(Utils.get_plant_damage(type))).set_delay(Utils.get_plant_attack_cooldown(type))
		asprite.animation = "pepper_effect"
		asprite.play()
		circle_hitbox.set_deferred("disabled", true)


#endregion: Pepper functions

func _on_area_entered(area):
	if allied:
		var parent = area.get_parent()
		if parent is Insect:
			match type:
				Plant.Type.PEPPER:
					attach_to_node(parent)
				_:
					parent.take_damage(damage)
					if delete_on_damage: delete()
	else:
		var parent = area.get_parent()
		if parent is Plant:
			parent.take_damage(damage)
			if delete_on_damage: delete()


func _on_animated_sprite_2d_frame_changed():
	if asprite.frame == disable_collision_after_frames:
		circle_hitbox.disabled = true
		potato_hitbox.disabled = true
		tomato_hitbox.disabled = true

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		chase_complete.emit()

func _on_animated_sprite_2d_animation_finished():
	if delete_on_finish: delete()
