extends CharacterBody2D

class_name Player

@onready var rat_collider: CollisionShape2D = $RatCollider
@onready var normal_collider: CollisionShape2D = $EsterCollider
@onready var animal_collider: CollisionShape2D = $AnimalCollider
@onready var left_ester_cast: RayCast2D = $LeftEsterCast
@onready var right_ester_cast: RayCast2D = $RightEsterCast
@onready var left_animal_cast: RayCast2D = $LeftAnimalCast
@onready var right_animal_cast: RayCast2D = $RightAnimalCast

@onready var ester_animator: AnimatedSprite2D = $Animations/EsterAnimations
@onready var rabbit_animator: AnimatedSprite2D = $Animations/RabbitAnimations
@onready var monkey_animator: AnimatedSprite2D = $Animations/MonkeyAnimations
@onready var rat_animator: AnimatedSprite2D = $Animations/RatAnimations


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
var spawnpoint: Vector2 = Vector2(0, 0)
# where you return to after you die
var flipped: bool = false
# whether you are facing left (the sprite is flipped) or not
var current_animator: AnimatedSprite2D

signal player_mask_change(new_mask: int)

func _ready() -> void:
	spawnpoint = global_position
	current_animator = ester_animator

func _physics_process(delta: float) -> void:
	current_animator.flip_h = flipped
	
	ester_animator.visible = current_animator == ester_animator
	rat_animator.visible = current_animator == rat_animator
	rabbit_animator.visible = current_animator == rabbit_animator
	monkey_animator.visible = current_animator == monkey_animator
	
	# Add the gravity.
	if not is_on_floor():
		if can_climb and (mask_index == 0 or mask_index == 2): 
			velocity.y = 0
		else:
			velocity += get_gravity() * delta
			current_animator.play("Jump")
	else:
		jump_count = 0
		lantern_bounces = 0

	# Climbing ladders
	if can_climb and (mask_index == 0 or mask_index == 2):
		if Input.is_action_pressed("jump"):
			velocity.y = CLIMB_VELOCITY
			if not is_on_floor():
				current_animator.play("Climb")
		elif Input.is_action_pressed("down") :
			velocity.y = CLIMB_VELOCITY * -1
		if not is_on_floor():
			current_animator.play("Climb")
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		if direction > 0:
			flipped = false
		if direction < 0:
			flipped = true
		if is_on_floor():
			current_animator.play("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			current_animator.play("Idle")
	
	if Input.is_action_just_pressed("jump"):
			if jump_count < max_jump_count:
				jump()
				jump_count += 1

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
		current_animator.play("Jump")

func mask_change(new_mask: int) -> void:
	if (left_ester_cast.is_colliding() or right_ester_cast.is_colliding()) and new_mask == 0:
		return
	else:
		mask_index = new_mask
		var mask: String = MASK_LIST[mask_index]
		
		# jumps:
		max_jump_count = 2 if mask == "rabbit" else 1
		
		# colliders:
		normal_collider.disabled = true if mask != "none" else false
		rat_collider.disabled = true if mask != "rat" else false
		animal_collider.disabled = true if mask != "rabbit" and mask != "monkey" else false
		
		# monkey collision mask:
		set_collision_mask_value(3, (mask=="monkey"))
		print(get_collision_mask_value(3))
		
		match mask: # is there a way to do this as part of the variable assignment?
			"none":
				current_animator = ester_animator
			"rabbit":
				current_animator = rabbit_animator
			"monkey":
				current_animator = monkey_animator
			"rat":
				current_animator = rat_animator
			_:
				current_animator = ester_animator
		player_mask_change.emit(new_mask)
		
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
