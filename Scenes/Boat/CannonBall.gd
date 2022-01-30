extends RigidBody

onready var shot_sounds : Spatial = $Shot

func _ready() -> void:
	apply_central_impulse(transform.basis.z*-1)
	
	shot_sounds.get_child(randi()%8).play()

func _screen_exited() -> void:
	pass # Replace with function body.
