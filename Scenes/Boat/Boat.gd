extends RigidBody

# ray length = 2

const FORCE_SCALE : float = 4.0# * 10.0

onready var area : Area = $Area as Area
onready var cast_holder : Spatial = $CastHolder as Spatial
var casts : Array

export var force_curve : Curve

func _ready() -> void:
	casts = cast_holder.get_children()

func _physics_process(delta: float) -> void:
	for cast in casts:
		var rcast : RayCast = cast as RayCast
		
		if rcast.is_colliding():
			var col_distance : float = rcast.global_transform.origin.distance_to(rcast.get_collision_point())
			# distance range 1.25 - 0
			col_distance = clamp(col_distance, 2.75, 3.25)
			# lower = more force
			col_distance = range_lerp(col_distance, 2.75, 3.25, 1, 0)
			# switch to interpolate baked once curve is finalized
			#add_force(Vector3.UP * force_curve.interpolate(col_distance) * FORCE_SCALE, rcast.transform.origin)
			add_force(transform.basis.y * force_curve.interpolate(col_distance) * FORCE_SCALE, rcast.transform.origin)



func _body_entered(body: Node) -> void:
	linear_damp = 2.0

func _body_exited(body: Node) -> void:
	linear_damp = 1.0
