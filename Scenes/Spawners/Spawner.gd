extends Spatial

var intensity : float = 0.0
var STORM_INTENSITY_1 = 0.2
var STORM_INTENSITY_2 = 0.4
var STORM_INTENSITY_3 = 0.6
var STORM_INTENSITY_4 = 0.8
var STORM_INTENSITY_5 = 1.0
var wind_direction = Vector2(0,0)
var state

enum {CALM, STORM_1, STORM_2, STORM_3, STORM_4, STORM_5}
const WAVE : PackedScene = preload("res://Scenes/Wave/WaveWave.tscn")
const KRAKEN : PackedScene = preload("res://Scenes/Tentacle/Tentacle.tscn")

onready var wave_timer = $wave_timer
onready var kraken_timer = $kraken_timer
onready var tween = $Tween

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if (intensity < STORM_INTENSITY_1):
		# Just Waves
		state = CALM
	elif (intensity >= STORM_INTENSITY_1 and intensity < STORM_INTENSITY_2):
		# Just Kraken
		state = STORM_1
	elif (intensity <= STORM_INTENSITY_2 and intensity < STORM_INTENSITY_3):
		# Kraken and Waves but not at the same time?
		state = STORM_2
	elif (intensity >= STORM_INTENSITY_3 and intensity < STORM_INTENSITY_4):
		# Occasion,al weaves, and heavy kraken
		state = STORM_3
	elif (intensity >= STORM_INTENSITY_4 and intensity < STORM_INTENSITY_5):
		# Occasion,al weaves, and heavy kraken
		state = STORM_4
	elif (intensity >= STORM_INTENSITY_5-0.1):
		# Send waves from all directions, and occasional kraken
		state = STORM_5

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func spawn_wave():
	var new_wave : Spatial = WAVE.instance()
	add_child(new_wave)
	new_wave.global_transform.origin.y = -5
	var starting = new_wave.global_transform.origin
	tween.interpolate_property(new_wave, "translation:y", null, 0, 2, Tween.TRANS_CUBIC, Tween.EASE_IN)	
	tween.start()
	new_wave.set_as_toplevel(true)
	new_wave.rotation = Vector3(0, -wind_direction.angle(),0)
	new_wave.scale.x = rand_range(2.0, 5.0)
	new_wave.scale.z = rand_range(3.0, 6.0)
	
func spawn_kraken():
	var new_kraken = KRAKEN.instance()
	add_child(new_kraken)
	new_kraken.scale = Vector3(rand_range(0.4,0.6), rand_range(0.4,0.5), rand_range(0.4,0.5))

func _on_wave_timer_timeout():
	if state == CALM:
		wave_timer.wait_time = 1
	elif state == STORM_1:
		wave_timer.wait_time = range_around(10)
		spawn_wave()	
	elif state == STORM_2:
		wave_timer.wait_time = 1
	elif state == STORM_3:
		wave_timer.wait_time = range_around(3)
		spawn_wave()
	elif state == STORM_4:
		wave_timer.wait_time = 1
	elif state == STORM_5:
		wave_timer.wait_time = range_around(5)
		spawn_wave()
	wave_timer.start()

func _on_kraken_timer_timeout():
	if state == CALM:
		kraken_timer.wait_time = 1
	elif state == STORM_1:
		kraken_timer.wait_time = 1
	elif state == STORM_2:
		kraken_timer.wait_time = range_around(10)
		spawn_kraken()
	elif state == STORM_3:
		kraken_timer.wait_time = 1
	elif state == STORM_4:
		kraken_timer.wait_time = range_around(5)
		spawn_kraken()
	elif state == STORM_5:
		kraken_timer.wait_time = range_around(3)
		spawn_kraken()
	kraken_timer.start()
	
func range_around (input):
	return rand_range(input+1, input-1)
