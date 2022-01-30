extends RigidBody

# ray length = 2

const CANNON : PackedScene = preload("res://Scenes/Boat/CannonBall.tscn")
const FORCE_SCALE : float = 4.0# * 10.0

onready var cannon_spawn : Spatial = $shiptextured/cannon001/CannonSpawn as Spatial
onready var area : Area = $Area as Area
onready var boat_sound : AudioStreamPlayer = $AudioStreamPlayer as AudioStreamPlayer
onready var cast_holder : Spatial = $CastHolder as Spatial
var casts : Array
var cooldown : bool = true

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
			var pos : Vector3 = rcast.transform.origin.rotated(Vector3.UP, rotation.y)
			#add_force(Vector3.UP * force_curve.interpolate(col_distance) * FORCE_SCALE, pos)
			add_force(transform.basis.y * force_curve.interpolate(col_distance) * FORCE_SCALE, pos)
	
	# ship turning
	var input : float = Input.get_axis("rotate_left", "rotate_right")
	boat_sound.volume_db = linear2db(abs(input))
	add_torque(Vector3(0, -input, 0))
	
	if Input.is_action_just_pressed("fire_ye_cannon") and not cooldown:
		spawn_ball()
	
	var flippy : float = global_transform.basis.y.dot(Vector3.UP)
	if flippy < -0.2 or global_transform.origin.y < -4:
		set_physics_process(false)
		boat_sound.volume_db = -80
		yield(get_tree().create_timer(1.0), "timeout")
		get_tree().call_group("Main", "end_game")
		queue_free()

func spawn_ball() -> void:
	cooldown = true
	$shiptextured/cannon001/CPUParticles.emitting = true
	$Cooldown.start()
	var new_ball : Spatial = CANNON.instance()
	cannon_spawn.add_child(new_ball)
	new_ball.set_as_toplevel(true)
	new_ball.global_transform = cannon_spawn.global_transform
	new_ball.shoot()
	
	add_torque(transform.basis.z * -20)

func hit(position : Vector3) -> void:
	add_torque(position.normalized() * 30)

func _body_entered(body: Node) -> void:
	linear_damp = 2.0

func _body_exited(body: Node) -> void:
	linear_damp = 1.0

func _on_Cooldown_timeout():
	cooldown = false
