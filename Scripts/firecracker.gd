extends RigidBody2D

@onready var explosion: Area2D = $Explosion
@onready var collider: CollisionShape2D = $CollisionShape2D

var exploding: bool = false
# whether the firecracker is flying or is frozen in place and exploding
var flight_timer: float = 3
# how long the firecracker should fly for before it explodes
var persist_timer: float = 1
#how long the explosion should last
var new_particles = load("res://Prefabs/firecracker_particles.tscn")

var particles_spawned: bool = false
# whether particles have already been spawned

signal death()

func _physics_process(delta: float) -> void:
	contact_monitor = true

	if not exploding:
		flight_timer -= delta
		exploding = flight_timer <= 0
		explosion.get_child(0).disabled = true
	else:
		freeze = true
		sleeping = true
		if not particles_spawned:
			var particles = new_particles.instantiate()
			add_child(particles)
			particles_spawned = true
		explosion.get_child(0).disabled = false
		persist_timer -= delta
		if persist_timer <= 0: queue_free()
		

func _on_body_entered(body: Node) -> void:
	if not exploding:
		exploding = true

func _on_explosion_area_entered(area: Area2D) -> void:
	print("BOOM")
	Global.player.death()
