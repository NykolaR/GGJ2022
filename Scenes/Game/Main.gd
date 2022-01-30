extends Node

enum {MAIN, GAME, OVER}
var state : int = MAIN

onready var water : Spatial = $Water as Spatial
onready var tween : Tween = $Tween as Tween
onready var animation : AnimationPlayer = $AnimationPlayer as AnimationPlayer
var intensity : float = 0.0 setget set_intensity

# waves last from 30s to 120s
var current_wave : int = 0

func _ready() -> void:
	tween.interpolate_property(self, "intensity", null, 0.7, 10.0, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()
	animation.play("Intensity")
	animation.stop(false)

func start_game() -> void:
	set_intensity(0)
	current_wave = 0

func ship_sunk() -> void:
	pass

func end_game() -> void:
	pass

func set_intensity(new : float) -> void:
	intensity = clamp(new, 0, 1)
	AmbientAudio.intensity = intensity
	water.intensity = intensity
	animation.seek(new, true)
