extends Node

const BOAT : PackedScene = preload("res://Scenes/Boat/Boat.tscn")
onready var boat_spawn : Spatial = $BoatSpawn

enum {MAIN, GAME, OVER}
var state : int = -1 setget set_state
enum {CALM, STORM}
var weather_state : int = CALM setget set_weather

onready var main_menu : Control = $MainMenu as Control
onready var game_over : Control = $GameOver as Control
onready var water : Spatial = $Water as Spatial
onready var tween : Tween = $Tween as Tween
onready var animation : AnimationPlayer = $AnimationPlayer as AnimationPlayer
onready var state_flip : Timer = $StateFlip as Timer
var intensity : float = 0.0 setget set_intensity

# waves last from 30s to 120s
var current_wave : int = 0

func _ready() -> void:
	animation.play("Intensity")
	animation.stop(false)
	set_state(MAIN)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire_ye_cannon"):
		match state:
			MAIN:
				if main_menu.modulate.a >= 0.9 and not tween.is_active():
					set_state(GAME)
					start_game()
			GAME:
				pass
			OVER:
				if game_over.modulate.a >= 0.9 and not tween.is_active():
					set_state(MAIN)

func start_game() -> void:
	var nboat : Spatial = BOAT.instance()
	boat_spawn.add_child(nboat)
	set_intensity(0)
	current_wave = 0
	weather_state = CALM
	tween.interpolate_property(main_menu, "modulate:a", null, 0.0, 1.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	state_flip.wait_time = 8 # (?)
	state_flip.start()

func end_game() -> void:
	state_flip.stop()
	set_weather(CALM)
	set_state(OVER)

func set_state(new : int) -> void:
	if state == new:
		return
	state = new
	match state:
		MAIN:
			tween.interpolate_property(main_menu, "modulate:a", null, 1.0, 3.0, Tween.TRANS_SINE, Tween.EASE_IN)
			tween.interpolate_property(game_over, "modulate:a", null, 0.0, 1.0, Tween.TRANS_QUAD, Tween.EASE_IN)
			tween.start()
		GAME:
			tween.interpolate_property(main_menu, "modulate:a", null, 0.0, 1.0, Tween.TRANS_QUAD, Tween.EASE_IN)
			tween.interpolate_property(game_over, "modulate:a", null, 0.0, 1.0, Tween.TRANS_QUAD, Tween.EASE_IN)
			tween.start()
		OVER:
			tween.interpolate_property(game_over, "modulate:a", null, 1.0, 3.0, Tween.TRANS_SINE, Tween.EASE_IN)
			tween.interpolate_property(main_menu, "modulate:a", null, 0.0, 1.0, Tween.TRANS_QUAD, Tween.EASE_IN)
			tween.start()

func set_intensity(new : float) -> void:
	intensity = clamp(new, 0, 1)
	AmbientAudio.intensity = intensity
	water.intensity = intensity
	animation.seek(new, true)
	
	if intensity > 0.8 and $LightningTimer.is_stopped():
		$LightningTimer.start()
	elif intensity < 0.8 and not $LightningTimer.is_stopped():
		$LightningTimer.stop()

func set_weather(new : int) -> void:
	if weather_state == new:
		return
	weather_state = new
	match weather_state:
		CALM:
			var nintensity : float = rand_range(0.0, 0.1)
			tween.interpolate_property(self, "intensity", null, nintensity, 3.0, Tween.TRANS_QUAD, Tween.EASE_IN)
			tween.start()
		STORM:
			var nintensity : float = clamp(0.2 + current_wave * 0.2, 0, 1)
			var time : float = 10.0
			tween.interpolate_property(self, "intensity", null, nintensity, time, Tween.TRANS_CUBIC, Tween.EASE_IN)
			tween.start()

func _LightningTimer_timeout() -> void:
	if randi()%10 == 0:
		$MeshInstance.show()
		$Timer.start()
	
	$LightningTimer.wait_time = rand_range(0.5, 2.5)

func _StateFlip_timeout() -> void:
	match weather_state:
		CALM:
			set_weather(STORM)
			current_wave += 1
			state_flip.wait_time = clamp(10 + current_wave * 20, 30, 120)
		STORM:
			set_weather(CALM)
			state_flip.wait_time = clamp(8 + current_wave * 2, 8, 20)
	
	state_flip.start()
