extends Resource
class_name Wave
## Set this to some time later than the last spawn time in the wave. Otherwise, the wave may end early
@export_range(0.0, 65.0, 0.1) var duration : float = 10.0
@export var wave_groups : Array[WaveGroup]
