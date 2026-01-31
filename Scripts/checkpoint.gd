extends Area2D

var activated: bool = false
var floating: String = "low"
# TODO: make lantern float higher when activated
var cycle: float = .5
var floatingUp: bool = true
signal checkpoint_set(spawnpoint: Vector2)

func _physics_process(delta: float) -> void:
	cycle += delta
	if cycle >= 1:
		floatingUp = not floatingUp
		cycle = 0
	
	if floating == "low":
		if floatingUp:
			get_child(1).position.y -= delta * 50
		else:
			get_child(1).position.y += delta * 50
		#print(cycle)

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player and not activated:
		checkpoint_set.emit(global_position)
		activated = true
		print("activated") # Replace with function body.
