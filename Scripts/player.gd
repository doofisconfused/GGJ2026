extends CharacterBody2D

class_name Player

@onready var rat_collider: CollisionShape2D = $RatCollider
@onready var normal_collider: CollisionShape2D = $NormalCollider
@onready var left_above_cast: RayCast2D = $LeftCast
@onready var right_above_cast: RayCast2D = $RightCast

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MASK_LIST = ["none", "rabbit", "monkey", "rat"]

var mask_index: int = 0
var jump_count: int = 0
var max_jump_count: int = 1
var can_climb: bool = false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0

	# Handle jump.
	if Input.is_action_just_pressed("jump") and jump_count < max_jump_count:
		jump()
		jump_count += 1

	

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
	
func jump() -> void:
		velocity.y = JUMP_VELOCITY

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
		
