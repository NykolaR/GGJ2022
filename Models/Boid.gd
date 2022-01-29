extends Spatial

var boids = []
var move_speed = 200
var perception_radius = 50
var velocity = Vector3()
var acceleration = Vector3()
var steer_force = 50.0
var alignment_force = 0.6
var cohesion_force = 0.6
var seperation_force = 1.0
var avoidance_force = 3.0


export (Array, Color) var colors 

func _ready():
	randomize()
	
	translation = Vector3(rand_range(0, get_viewport().size.x), rand_range(0, get_viewport().size.y), 1.0)
	velocity = Vector3(rand_range(-1, 1), rand_range(-1, 1), 0).normalized() * move_speed


func _process(delta):
	
	var neighbors = get_neighbors(perception_radius)
	
	acceleration += process_alignments(neighbors) * alignment_force
	acceleration += process_cohesion(neighbors) * cohesion_force
	acceleration += process_seperation(neighbors) * seperation_force

#	if is_obsticle_ahead():
#		acceleration += process_obsticle_avoidance() * avoidance_force
		
	velocity += acceleration * delta
	rotation = Vector3(velocity.angle(), 0.0, 0.0)
	
	translate(Vector3((velocity * delta).x, 0.0, (velocity * delta).y))
	
	translation.x = wrapf(translation.x, -32, translation.x + 32)
	translation.y = wrapf(translation.y, -32, translation.y + 32)

func process_cohesion(neighbors):
	var vector = Vector3()
	if neighbors.empty():
		return vector
	for boid in neighbors:
		vector += boid.translation
	vector /= neighbors.size()
	return steer((vector - translation).normalized() * move_speed)
		

func process_alignments(neighbors):
	var vector = Vector3()
	if neighbors.empty():
		return vector
		
	for boid in neighbors:
		vector += boid.velocity
	vector /= neighbors.size()
	return steer(vector.normalized() * move_speed)

func process_seperation(neighbors):
	var vector = Vector3()
	var close_neighbors = []
	for boid in neighbors:
		if translation.distance_to(boid.translation) < perception_radius / 2:
			close_neighbors.push_back(boid)
	if close_neighbors.empty():
		return vector
	
	for boid in close_neighbors:
		var difference = translation - boid.translation
		vector += difference.normalized() / difference.length()
	
	vector /= close_neighbors.size()
	return steer(vector.normalized() * move_speed)
	

func steer(var target):
	var steer = target - velocity
	steer = steer.normalized() * steer_force
	return steer
	
#func is_obsticle_ahead():
#	for ray in detectors.get_children():
#		if ray.is_colliding():
#			return true
#	return false

#func process_obsticle_avoidance():
#	for ray in sensors.get_children():
#		if not ray.is_colliding():
#			return steer( (ray.cast_to.rotated(ray.rotation + rotation)).normalized() * move_speed )
#
#	return Vector2.ZERO

func get_neighbors(view_radius):
	var neighbors = []

	for boid in boids:
		if translation.distance_to(boid.translation) <= view_radius and not boid == self:
			neighbors.push_back(boid)
	return neighbors
