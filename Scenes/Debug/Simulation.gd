extends Spatial

# Boids temp
#onready var BOIDS_COUNT = 300
#
#onready var boid_scene = preload("res://Models/seagull.tscn")
#onready var boids_container = $Boids
#
#var boids = []
#
#func _ready():
#
#	for i in BOIDS_COUNT:
#		var boid = boid_scene.instance()
#		boid.move_speed = 72
#		boid.steer_force = 150
#		boid.alignment_force = 0.5
#		boid.cohesion_force = 0.5
#		boid.seperation_force = 1
#		boids_container.add_child(boid)
#		boids.push_back(boid)
#
#
#	for boid in boids_container.get_children():
#		boid.boids = boids
#

onready var speed = 0.6
onready var randomAngle = randf()

func _process(delta):
	rotate_y(delta * speed)
	rotate_z(cos(delta + randomAngle) * 0.001)
