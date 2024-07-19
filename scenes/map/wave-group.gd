extends Resource
class_name WaveGroup

@export var type : Insect.Type
@export var count : int
@export_range(0.0, 60.0, 0.1) var spawn_time : float
@export_group("Stream Spawning")
@export var streams : bool = false
@export_range(0.1, 60.0, 0.1) var stream_duration : float  
