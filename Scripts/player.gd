extends CharacterBody2D

class_name Player

@onready var rat_collider: CollisionShape2D = $RatCollider
@onready var normal_collider: CollisionShape2D = $NormalCollider
@onready var left_above_cast: RayCast2D = $LeftCast
@onready var right_above_cast: RayCast2D = $RightCast

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const BOUNCE_VELOCITY = -600.0
const CLIMB_VELOCITY = -200.0
const MASK_LIST = ["none", "rabbit", "monkey", "rat"]


var mask_index: int = 0
# index in the MASK_LIST array representing current mask
var jump_count: float = 0.0
# number of jumps you have left before touching the ground
var max_jump_count: int = 1
# number of jumps you can make at once
var can_climb: bool = false
# whether you're in a ladder
var lantern_bounces: int = 0
# number of times you've bounced on a lantern since leaving the ground
var spawnpoint: Vector2 = Vector2(934.0, 553.0)

func _ready() -> void:
	print(spawnpoint)
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0
		lantern_bounces = 0

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if jump_count < max_jump_count:
			jump()
			jump_count += 1
	
	# Climbing ladders
	if Input.is_action_pressed("jump") and can_climb:
		velocity.y = CLIMB_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
 # none, rabbit, monkey, rat
	if Input.is_action_just_pressed("mask_next"):
		mask_change(mask_index + 1 if mask_index + 1 < MASK_LIST.size() else 0)
		print(MASK_LIST[mask_index])
	elif Input.is_action_just_pressed("mask_last"):
		mask_change(mask_index - 1 if mask_index - 1 > -1 else 3)
		print(MASK_LIST[mask_index])
	move_and_slide()
	
func jump(power = JUMP_VELOCITY) -> void:
		velocity.y = power

func mask_change(new_mask: int) -> void:
	if left_above_cast.is_colliding() or right_above_cast.is_colliding():
		return
	else:
		mask_index = new_mask
		var mask: String = MASK_LIST[mask_index]
		
		# rabbit:
		max_jump_count = 2 if mask == "rabbit" else 1
		
		# rat:
		normal_collider.disabled = true if mask == "rat" else false
		rat_collider.disabled = not normal_collider.disabled
		
		# monkey:
		set_collision_mask_value(3, (mask=="monkey"))
		print(get_collision_mask_value(3))
		
func _on_bounce_area_body_entered(_body: Node2D) -> void:
	if mask_index == 2:
		jump(BOUNCE_VELOCITY * (1.0 + (lantern_bounces * 1.5) / 10.0))
		print(lantern_bounces)
		if not lantern_bounces >= 3:
			lantern_bounces += 1
		# this math is arbitrary and might be good to discuss tomorrow

func _on_checkpoint_set(new_spawnpoint: Vector2) -> void:
	spawnpoint = new_spawnpoint 
	print(spawnpoint)



func _on_death() -> void:
	global_position = spawnpoint # Replace with function body.
