extends Node

onready var calm : AudioStreamPlayer = $Calm as AudioStreamPlayer
onready var wind : AudioStreamPlayer = $Wind as AudioStreamPlayer
onready var storm : AudioStreamPlayer = $Storm as AudioStreamPlayer
onready var kraken_song : AudioStreamPlayer = $Kraken as AudioStreamPlayer

export var calm_ramp : Curve
export var wind_ramp : Curve
export var storm_ramp : Curve

export(float, 0, 1) var intensity : float = 0.0 setget set_intensity

var kraken_volume : float = 0.0

func _ready() -> void:
	set_intensity(intensity)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen

func _process(delta: float) -> void:
	# set kraken volume
	if get_tree().get_nodes_in_group("Kraken").size() > 0:
		kraken_volume = lerp(kraken_volume, 1.0, 0.1 * delta)
	else:
		kraken_volume = lerp(kraken_volume, 0.0, 0.5 * delta)
	
	kraken_song.volume_db = linear2db(kraken_volume)

func set_intensity(new : float) -> void:
	intensity = clamp(new, 0, 1)
	
	calm.volume_db = linear2db(calm_ramp.interpolate_baked(intensity))
	wind.volume_db = linear2db(wind_ramp.interpolate_baked(intensity))
	storm.volume_db = linear2db(storm_ramp.interpolate_baked(intensity))
