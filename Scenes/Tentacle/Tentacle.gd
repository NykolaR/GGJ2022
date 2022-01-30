extends Spatial

enum {RISING, STEERING, ATTACKING, ATTACK_COOLDOWN, DYING, DEAD}

onready var impact_sounds : Spatial = $impact_sounds
onready var death_sounds : Spatial = $death_sounds

var MAX_IMPACT_SOUNDS = 2
var MAX_DEATH_SOUNDS = 3

var player_position
var speed
var state
var MAX_SPEED = .4
var SLOW_RADIUS = 30
var MASS = 2.5
var velocity: Vector2
var target
var angle
var cooldown_time = 120
onready var tween = $Tween
var old_pos

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	player_position = Vector3(0,0,0)
	$Armature/Skeleton/SkeletonIK.start()
	
	angle = Vector2(0,10)
	angle = angle.rotated(rand_range(-PI, PI))
	transform.origin.x = angle.x
	transform.origin.z = angle.y
	
	var target_position_x = - player_position.x + global_transform.origin.x
	var target_position_z = - player_position.z + global_transform.origin.z
	target = Vector2(target_position_x, target_position_z).normalized() * rand_range(3,5)
	
	$AnimationPlayer.play("rise")
	state = RISING

func _process(delta):
	print (state)
	if state == RISING:
		pass
	elif state == STEERING:
		transform.origin.x += velocity.x
		transform.origin.z += velocity.y
		velocity = arrive(velocity, 
				Vector2(transform.origin.x,transform.origin.z), 
				target)
		var pos2 = Vector2 (global_transform.origin.x, global_transform.origin.z)
		if  pos2.distance_squared_to(target) < 1 :
			state = ATTACKING
	elif state == ATTACKING:
		var pos = $"IK Target".transform.origin
		tween.interpolate_property($"IK Target", "translation", null, to_local(Vector3(0,0,0)), 0.5, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
		$Timer.start()
		tween.interpolate_property($"IK Target", "translation", to_local(Vector3(0,0,0)), pos, 2, Tween.TRANS_CUBIC, Tween.EASE_IN, 0.5)
		tween.start()
		state = ATTACK_COOLDOWN
	elif state == ATTACK_COOLDOWN:
		pass
	elif state == DYING:
		$AnimationPlayer.stop()
		tween.interpolate_property($"IK Target", "translation", null, Vector3($"IK Target".transform.origin.x+7, $"IK Target".transform.origin.y-15, $"IK Target".transform.origin.z+7), 2, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
		tween.interpolate_property(self, "translation", null, Vector3(transform.origin.x, transform.origin.y-2, transform.origin.z), 1, Tween.TRANS_BACK, Tween.EASE_IN_OUT, 2)
		tween.start()
		state = DEAD
	elif state == DEAD:
		pass

func spawn (player):
	pass

func _on_AnimationPlayer_animation_finished(rise):
	var angle2 = angle.tangent()
	if randi() % 2 == 0:
		angle2 = angle.rotated(PI)
	velocity = angle2.normalized()*MAX_SPEED
	$AnimationPlayer.play("wiggling")
	state = STEERING

func arrive ( my_velocity: Vector2,
		global_position: Vector2,
		target_position: Vector2) -> Vector2: 
	var to_target = global_position.distance_to(target_position)
	var desired_velocity = (target_position - global_position).normalized() * MAX_SPEED
	if to_target < SLOW_RADIUS:
		desired_velocity *= (to_target / SLOW_RADIUS) * 0.8 + 0.2
	var steering = (desired_velocity-my_velocity) / MASS
	return my_velocity *.99 + steering * .01

func _on_Tween_tween_all_completed():
	if state == ATTACK_COOLDOWN:
		state = ATTACKING
	if state == DEAD:
		queue_free()

func hit():
	if state != DEAD:
		impact_sounds.get_child(randi()%MAX_IMPACT_SOUNDS).play()
		death_sounds.get_child(randi()%MAX_DEATH_SOUNDS).play()
		state = DYING

func _on_Timer_timeout():
	get_tree().call_group("player", "hit", global_transform.origin)
