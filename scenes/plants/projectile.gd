extends Area2D
class_name Projectile

#region: Globals
var type : Plant.Type

var damage : int
var speed : float
var radius : float
var lifespan := 10.0

var dir : Vector2
var allied := true
var should_fire := true
var deleting := false
var offset := Vector2(0, -8)

@onready var holder = $Holder
@onready var shadow = $Shadow
@onready var asprite : AnimatedSprite2D = $Holder/AnimatedSprite2D
@onready var circle_hitbox : CollisionShape2D = $Hitbox
#endregion: Globals

#region: Universal functions
# Called when the node enters the scene tree for the first time.
func _ready():
	pick_values_on_type()
	if should_fire:
		_fire()


func pick_values_on_type():
	match type:
		Plant.Type.BROCCOLI:
			asprite.animation = "floret"
			circle_hitbox.shape.radius = radius

func _fire():
	var tween : Tween = create_tween()
	var final_pos := position + dir * speed * lifespan 
	tween.tween_property(self, "position", final_pos, lifespan)
	tween.tween_callback(delete)

func delete():
	deleting = true
	# Add deletion VFX here
	queue_free()

func _physics_process(delta):
	asprite.position = position + offset
	asprite.rotation = rotation
	shadow.global_rotation = 0
#endregion: Universal functions


func _on_area_entered(area):
	if allied:
		var parent = area.get_parent()
		if parent is Insect:
			match type:
				Plant.Type.BROCCOLI:
					parent.take_damage(damage)
					delete()
	else:
		pass # make enemy projectile hit plant
