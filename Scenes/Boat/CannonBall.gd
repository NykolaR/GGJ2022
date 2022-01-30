extends RigidBody

func _ready() -> void:
	apply_central_impulse(transform.basis.z*-1)

