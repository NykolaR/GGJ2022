extends Spatial

var intensity : float = 0.0
var STORM_1 = 0.4
var STORM_2 = 0.6
var STORM_3 = 0.8
var STORM_4 = 1.0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	print(intensity)
	if (intensity < STORM_1):
		pass
	elif (intensity >= STORM_1 and intensity >= STORM_2):
		pass
	elif (intensity >= STORM_2 and intensity >= STORM_3):
		pass
	elif (intensity >= STORM_3 and intensity >= STORM_4):
		pass
	elif (intensity == STORM_4):
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
