extends Panel
class_name Minimap
var icon_image = preload("res://assets/ui/minimap-icon.png")
var indicator_image = preload("res://assets/ui/buttons/minimap-indicator.png")
var icons := {}

@onready var sub_viewport : SubViewport = $SubViewportContainer/SubViewport
@onready var update_timer : Timer = $UpdateTimer
@onready var main_permanent_node = get_tree().get_first_node_in_group("main").get_child(0)
@onready var main : Main = get_tree().get_first_node_in_group("main")
@onready var floor : TileMapLayer = get_tree().get_first_node_in_group("floor")

func _ready():
	for child in sub_viewport.get_children():
		if not child is Camera2D:
			sub_viewport.remove_child(child)
	_add_initial_icons()

# NOTE: Currently only really adds the player
func _add_initial_icons():
	for child in main_permanent_node.get_children():
		add_icon(child)
	for cell_coords in floor.get_used_cells():
		var atlas_coords = floor.get_cell_atlas_coords(cell_coords)
		match atlas_coords:
			Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1),\
			Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2):
				add_map_icon(floor.map_to_local(cell_coords)) 

func update_minimap():
	for parent in icons.keys():
		if not (parent and is_instance_valid(parent)):
			icons[parent].queue_free()
			icons.erase(parent)
		else:
			icons[parent].position = parent.position

func _process(delta):
	update_minimap()

func add_map_icon(pos):
	var sprite = Sprite2D.new()
	sprite.texture = icon_image
	sprite.modulate = Color(1, 1, 1, 0.5)
	sprite.scale = Vector2(1, 0.5)
	sprite.position = pos
	sub_viewport.add_child(sprite)

func add_icon(parent):
	var sprite = Sprite2D.new()
	sprite.texture = icon_image
	if parent is Spawner:
		sprite.modulate = Color(0.6, 0, 0)
		sprite.scale = Vector2(6, 6)
	elif parent is Player:
		sprite.modulate = Color(0, 0.8, 1.0)
		sprite.scale = Vector2(3, 3)
	elif parent is Plant:
		sprite.modulate = Color(0, 1, 0)
		if parent.type == Plant.Type.FOOD_SUPPLY:
			sprite.modulate = Color(0.25, 0, 0.75)
			sprite.scale = Vector2(3, 3)
	elif parent is Insect:
		sprite.modulate = Color(1, 0, 0)
	else:
		return
	sprite.position = parent.position
	icons[parent] = sprite
	sprite.modulate.a = 0
	create_tween().tween_property(sprite, "modulate:a", 1.0, 0.5)
	sub_viewport.add_child(sprite)
	return sprite

func add_indicator(pos):
	var sprite = Sprite2D.new()
	sprite.texture = indicator_image
	sprite.position = pos
	var tween = create_tween().set_parallel()
	tween.tween_property(sprite, "scale", Vector2(5, 5), 3.0).from(Vector2(0.5, 0.5)).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "modulate", Color(1,1,1,0), 3.0).from(Color(2,2,2,1)).set_trans(Tween.TRANS_QUART)
	tween.chain().tween_callback(sprite.queue_free)
	sub_viewport.add_child(sprite)

func remove_icon(parent):
	if parent is Plant:
		add_indicator(parent.position)
	if icons.has(parent):
		icons[parent].queue_free()
		icons.erase(parent)

func _on_update_timer_timeout():
	update_minimap()
