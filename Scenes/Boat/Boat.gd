extends RigidBody

# ray length = 2

onready var cast_holder : Spatial = $CastHolder
onready var casts : Array

func _ready() -> void:
	casts = cast_holder.get_children()

func _physics_process(delta: float) -> void:
	for cast in casts:
		var rcast : RayCast = cast as RayCast
		
		if rcast.is_colliding():
			var col_distance : float = rcast.global_transform.origin.distance_to(rcast.get_collision_point())
			add_force(Vector3.ZERO, rcast.transform.origin)


