extends RigidBody

onready var shot_sounds : Spatial = $Shot
onready var splash_sounds : Spatial = $WaterHit

func shoot() -> void:
	apply_central_impulse(transform.basis.x*-20+Vector3.UP*3)
	
	shot_sounds.get_child(randi()%8).play()

func _screen_exited() -> void:
	queue_free()

func _body_entered(body: Node) -> void:
	splash_sounds.get_child(randi()%3).play()
	linear_velocity *= 0.5
	get_tree().call_group("Water", "add_ring", transform.origin)

func _on_Area_area_entered(area: Area) -> void:
	if area.get_parent().has_method("hit"):
		area.get_parent().hit()
		linear_velocity *= 0.1
