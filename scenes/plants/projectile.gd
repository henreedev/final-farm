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
var chase_progress := 0.0
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

#endregion: Globals

#region: Universal functions
# Called when the node enters the scene tree for the first time.
func _ready():
	pick_values_on_type()
	if should_fire:
		_fire()


func pick_values_on_type():
	if allied:
		asprite.animation = Utils.get_plant_string(type) 
	else:
		asprite.animation = Utils.get_insect_string(insect_type)
	circle_hitbox.shape.radius = radius
	start_pos = position
	if target:
		target_last_pos = target.position
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
		Plant.Type.PEPPER:
			chase_duration = 0.5
			has_shadow = false
			fires_to_target = true
		Plant.Type.WATERMELON:
			circle_hitbox.disabled = true
			has_shadow = false
			fires_to_target = true
			chase_duration = 2.5
func _fire():
	var tween : Tween = create_tween()
	if fires_to_target:
		tween.tween_property(self, "chase_progress", 1.0, chase_duration)
	else:
		var final_pos := position + dir * speed * lifespan 
		tween.tween_property(self, "position", final_pos, lifespan)
		tween.tween_callback(delete)

func delete():
	deleting = true
	# Add deletion VFX here
	queue_free()

func _physics_process(delta):
	if target:
		position = Utils.calc_point_on_arc_between(start_pos, target.position, chase_progress)
		target_last_pos = target.position
	else: 
		position = Utils.calc_point_on_arc_between(start_pos, target.position, chase_progress)
		circle_hitbox.disabled = false
	asprite.position = position + offset
	asprite.rotation = rotation
	shadow.global_rotation = 0
#endregion: Universal functions

func _on_area_entered(area):
	if allied:
		var parent = area.get_parent()
		if parent is Insect:
			match type:
				Plant.Type.PEPPER:
					reparent(parent)
					var tween : Tween = parent.create_tween().set_loops()
					tween.tween_callback(parent.take_damage.bind(Utils.get_plant_damage(type)))
					tween.tween_interval(Utils.get_plant_attack_cooldown(type))
					asprite.animation = "pepper_effect"
					asprite.play()
				Plant.Type.BROCCOLI:
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


func _on_animated_sprite_2d_animation_finished():
	if delete_on_finish: delete()
