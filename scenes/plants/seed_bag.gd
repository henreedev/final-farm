extends AnimatedSprite2D
class_name SeedBag

var type : Plant.Type = Plant.Type.EGGPLANT
@onready var node = $Node
@onready var player : Player = get_tree().get_first_node_in_group("player")
@onready var main = get_tree().get_first_node_in_group("main")
@onready var path : Path2D = $Node/Path2D
@onready var path_follow : PathFollow2D = $Node/Path2D/PathFollow2D
var thrown = false
var arrived = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pick_animation()
	create_tween().tween_property(self, "scale", Vector2(0.5, 0.5), 0.5).set_trans(Tween.TRANS_CUBIC)

func delete():
	reparent(main)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0, 0), 0.2).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(queue_free)

func throw(final_pos, duration):
	reparent(main)
	thrown = true
	create_tween().tween_property(self, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_CUBIC)
	#var arc_points = Utils.calc_arc_between(global_position, final_pos)
	#for point in arc_points:
		#path.curve.add_point(point)
	#create_tween().tween_property(path_follow, "progress_ratio", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	Utils.tween_arc_between(self, global_position, final_pos, duration)

func arrive():
	arrived = true

func pick_animation():
	match type:
		Plant.Type.EGGPLANT:
			animation = "eggplant"
		_:
			print("SEED TYPE ANIMATION NOT DEFINED (seed_bag.gd)")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if thrown and not arrived:
		#position = path_follow.position
		#rotation = path_follow.rotation - PI / 2
		pass
