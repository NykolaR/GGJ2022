extends Node

onready var calm : AudioStreamPlayer = $Calm as AudioStreamPlayer
onready var wind : AudioStreamPlayer = $Wind as AudioStreamPlayer
onready var storm : AudioStreamPlayer = $Storm as AudioStreamPlayer

export var calm_ramp : Curve
export var wind_ramp : Curve
export var storm_ramp : Curve

export(float, 0, 1) var intensity : float = 0.0 setget set_intensity

func _ready() -> void:
	set_intensity(intensity)

func set_intensity(new : float) -> void:
	intensity = clamp(new, 0, 1)
	
	calm.volume_db = linear2db(calm_ramp.interpolate_baked(intensity))
	wind.volume_db = linear2db(wind_ramp.interpolate_baked(intensity))
	storm.volume_db = linear2db(storm_ramp.interpolate_baked(intensity))
