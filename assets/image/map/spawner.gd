extends Node2D
class_name Spawner


var spawn_radius := 50.0
var insect_scene : PackedScene = preload("res://scenes/insects/insect.tscn")
var insects_to_spawn : Array[WaveGroup] 
var progress := 0.0
@onready var main : Main = get_tree().get_first_node_in_group("main")

func begin_spawning():
	var spawner_tween = create_tween().set_parallel()
	for wave_group : WaveGroup in insects_to_spawn:
		spawner_tween.tween_callback(_spawn_group.bind(wave_group)).set_delay(wave_group.spawn_time)
		
func _spawn_group(wave_group : WaveGroup):
	if wave_group.streams:
		_spawn_group_stream(wave_group)
	else:
		for i in range(wave_group.count):
			_spawn_insect(wave_group.type)
	

func _spawn_group_stream(wave_group : WaveGroup):
	var stream_tween = create_tween().set_parallel()
	var interval = wave_group.stream_duration / wave_group.count
	for i in range(wave_group.count):
		stream_tween.tween_callback(_spawn_insect.bind(wave_group.type)).set_delay(i * interval)

func _spawn_insect(type : Insect.Type):
	var insect : Insect = insect_scene.instantiate()
	insect.type = type
	var random_offset = Vector2(randf_range(-spawn_radius, spawn_radius), \
								randf_range(-spawn_radius, spawn_radius) / 2)
	insect.position = position + random_offset
	main.add_child(insect)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
