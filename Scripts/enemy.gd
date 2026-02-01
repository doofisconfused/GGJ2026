extends CharacterBody2D

@onready var upper_ray: RayCast2D = $UpperRay
@onready var middle_ray: RayCast2D = $MiddleRay
@onready var lower_ray: RayCast2D = $LowerRay
@onready var enemy_sprite: Sprite2D = $EnemySprite
@onready var watching_eye: Sprite2D = $WatchedSymbol
@onready var ester_collider: CollisionShape2D = $/root/GameMaster/Player/EsterCollider

const SPEED = 200.0
const TIME_TO_AGGRO: float = 3
const TIME_TO_COOLDOWN: float = 10

var walkDistance: float = 500
var origin: Vector2 = Vector2(0,0)
var destination: Vector2 = Vector2(0,0)
# walks walkDistance px from origin towards destination
var facing_right: bool = true

var aggression_timer: float = TIME_TO_AGGRO
# time before enemy leaves suspicon and enters aggression - will decrement if player is not seen
var peace_timer: float = TIME_TO_COOLDOWN
# time before enemy leaves aggression - will reset if player is caught

var enemy_suspicion: String = "normal" # normal, suspicion, aggro
# normal - enemy does not see the player. 
# suspicion - enemy will enter aggro if player stays in sight for too long. monkey triggers this
# aggro - enemy chases limited distance after player before returning to suspicion, then normal

var player_changed: bool = false

func _ready() -> void:
	origin = global_position
	destination = global_position + Vector2(walkDistance if facing_right else walkDistance * -1, global_position.y)
	print(origin)
	print(destination)

func _physics_process(delta: float) -> void:
	enemy_sprite.flip_h = not facing_right
	upper_ray.target_position = Vector2(0, 400 if facing_right else -400)
	middle_ray.target_position = Vector2(0, 400 if facing_right else -400)
	lower_ray.target_position = Vector2(0, 400 if facing_right else -400)
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var scanned_player
	if upper_ray.is_colliding():
			if upper_ray.get_collider().is_class("CharacterBody2D"):
				scanned_player = upper_ray.get_collider()
			elif lower_ray.get_collider().is_class("CharacterBody2D"):
				scanned_player = lower_ray.get_collider()
			elif middle_ray.get_collider().is_class("CharacterBody2D"):
				scanned_player = middle_ray.get_collider()
	if scanned_player:
		if scanned_player.mask_index == 0:
			enemy_suspicion = "aggro"
			peace_timer = TIME_TO_COOLDOWN
		if scanned_player.mask_index == 2:
			enemy_suspicion = "suspicious"
		if player_changed:
			enemy_suspicion = "aggro"
		
	if enemy_suspicion == "normal":
		if origin.x < destination.x:
			if global_position.x >= destination.x:
				facing_right = false
			if global_position.x < origin.x:
				print(global_position.x)
				facing_right = true
		else:
			if global_position.x >= destination.x:
				facing_right = true
			if global_position.x <= origin.x:
				facing_right = false
				
	if enemy_suspicion == "aggro":
		print("i'm angry!!!!!!!")
		enemy_suspicion = "normal"
	
	# if enemy is outside the two points set for them to walk, they flip
	# sorry there's probably a more eloquent way to do this. if it doesn't work
	# or you want it done differently i'll change it
	
	velocity.x = SPEED * (1 if facing_right else -1)
	move_and_slide()
	



func _on_player_player_mask_change(_new_mask: int) -> void:
	player_changed = true
