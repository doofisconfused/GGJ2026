extends CharacterBody2D

@onready var upper_ray: RayCast2D = $UpperRay
@onready var middle_ray: RayCast2D = $MiddleRay
@onready var lower_ray: RayCast2D = $LowerRay
@onready var enemy_sprite: Sprite2D = $EnemySprite
@onready var watching_eye: Sprite2D = $WatchedSymbol
@onready var wall_detector: CollisionShape2D = $WallDetector/CollisionShape2D
@onready var game_master: Node2D = $/root/GameMaster

const SPEED: float = 200.0
const AGGRO_SPEED: float =  300.0
const TIME_TO_AGGRO: float = 3
const TIME_TO_COOLDOWN: float = 10

var firecracker = load("res://Prefabs/firecracker.tscn")

var walkDistance: float = 500
var origin: Vector2 = Vector2(0,0)
var destination: Vector2 = Vector2(0,0)
# walks walkDistance px from origin towards destination
var facing_right: bool = true

var aggression_timer: float = TIME_TO_AGGRO
# time before enemy leaves suspicon and enters aggression - will decrement if player is not seen
var peace_timer: float = TIME_TO_COOLDOWN
# time before enemy leaves aggression/suspicion - will reset if player is caught

var enemy_suspicion: String = "normal" # normal, suspicion, aggro
# normal - enemy does not see the player. 
# suspicion - enemy will enter aggro if player stays in sight for too long. monkey triggers this
# aggro - enemy chases limited distance after player before returning to suspicion, then normal

var player_changed: bool = false
# true if the player changed masks this frame. used for determining aggro.

var watched_player: CharacterBody2D # permanent reference to the player after found by raycast
var firecracker_timer: float = 3 # time before next firecracker is thrown

func _ready() -> void:
	set_walk_points()

func _physics_process(delta: float) -> void:
	enemy_sprite.flip_h = not facing_right
	if enemy_suspicion != "aggro":
		upper_ray.target_position = Vector2(0, 400 if facing_right else -400)
		middle_ray.target_position = Vector2(0, 400 if facing_right else -400)
		lower_ray.target_position = Vector2(0, 400 if facing_right else -400)
	else:
		upper_ray.target_position = Vector2(0, 600 if facing_right else -600)
		middle_ray.target_position = Vector2(0, 600 if facing_right else -600)
		lower_ray.target_position = Vector2(0, 600 if facing_right else -600)
	wall_detector.position.x = 14 if facing_right else -14
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var scanned_player
	if upper_ray.is_colliding():
			if upper_ray.get_collider().is_class("CharacterBody2D"):
				scanned_player = upper_ray.get_collider()
	elif lower_ray.is_colliding():
			if lower_ray.get_collider().is_class("CharacterBody2D"):
				scanned_player = lower_ray.get_collider()
	elif middle_ray.is_colliding():
			if middle_ray.get_collider().is_class("CharacterBody2D"):
				scanned_player = middle_ray.get_collider()
	if scanned_player:
		if scanned_player.mask_index == 0:
			enemy_suspicion = "aggro"
			peace_timer = TIME_TO_COOLDOWN
		elif player_changed:
			enemy_suspicion = "aggro"
			peace_timer = TIME_TO_COOLDOWN
		elif scanned_player.mask_index == 2:
			if enemy_suspicion != "aggro": 
				enemy_suspicion = "suspicious"
				peace_timer = TIME_TO_COOLDOWN
				aggression_timer -= delta
		else: peace_timer -= delta
		watched_player = scanned_player
	else: peace_timer -= delta
					
		
	if enemy_suspicion == "normal":
		peace_timer = TIME_TO_COOLDOWN
		aggression_timer = TIME_TO_AGGRO
		watching_eye.modulate = Color.WHITE
		if origin.x < destination.x:
			if global_position.x >= destination.x:
				facing_right = false
			if global_position.x < origin.x:
				print(global_position.x)
				facing_right = true
		else:
			if global_position.x <= destination.x:
				facing_right = true
			if global_position.x >= origin.x:
				facing_right = false
		watching_eye.modulate = Color.WHITE
		velocity.x = SPEED * (1 if facing_right else -1)

				
	if enemy_suspicion == "aggro":
		aggression_timer = TIME_TO_AGGRO
		peace_timer -= delta
		firecracker_timer -= delta
		watching_eye.modulate = Color.WHITE.lerp(Color.RED, peace_timer / TIME_TO_COOLDOWN)
		if peace_timer <= 0: enemy_suspicion = "normal"
		
		if global_position.distance_to(watched_player.global_position) > 10:
			facing_right = watched_player.global_position.x > global_position.x
			velocity.x = AGGRO_SPEED * (1 if facing_right else -1)
		else: 
			velocity.x = 0
		
		if firecracker_timer <= 0:
			firecracker_timer = randf_range(2.5, 3.5)
			throw_firecracker(watched_player.global_position)
			
		
		

	if enemy_suspicion == "suspicious":
		print(peace_timer)
		watching_eye.modulate = Color.RED.lerp(Color.YELLOW, aggression_timer / TIME_TO_AGGRO)
		facing_right = watched_player.global_position.x > global_position.x
		if aggression_timer <= 0: enemy_suspicion = "aggro"
		if peace_timer <= 0: enemy_suspicion = "normal"
		
		velocity.x = 0 
		if origin.x < destination.x:
			if global_position.x >= destination.x:
				facing_right = false
			if global_position.x < origin.x:
				print(global_position.x)
				facing_right = true
		else:
			if global_position.x <= destination.x:
				facing_right = true
			if global_position.x >= origin.x:
				facing_right = false
	
	player_changed = false
	move_and_slide()

func set_walk_points() -> void:
	origin = global_position
	destination = global_position + Vector2(walkDistance if facing_right else walkDistance * -1, global_position.y)
	print(origin)
	print(destination)
	

func _on_player_player_mask_change(_new_mask: int) -> void:
	player_changed = true


func _on_wall_detector_body_entered(body: Node2D) -> void:
	if body.is_class("StaticBody2D"):
		facing_right = not facing_right
	set_walk_points()
	

func throw_firecracker(playerPos: Vector2) -> void:
	var new_firecracker: RigidBody2D = firecracker.instantiate()
	get_parent().add_child(new_firecracker)
	new_firecracker.position = global_position
	new_firecracker.apply_central_impulse((new_firecracker.global_position*-1+playerPos)
		.normalized() * 700 + Vector2(0, -700))
	


func _on_player_reset_aggro() -> void:
	enemy_suspicion = "normal" # Replace with function body.
