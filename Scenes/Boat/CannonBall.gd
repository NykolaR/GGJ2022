extends RigidBody

onready var shot_sounds : Spatial = $Shot

func shoot() -> void:
	apply_central_impulse(transform.basis.x*-20+Vector3.UP*3)
	
	shot_sounds.get_child(randi()%8).play()

func _screen_exited() -> void:
	print("bye")
	queue_free()
