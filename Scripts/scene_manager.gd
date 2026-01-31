extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#load_scene("res://Scenes/main_menu.tscn")
	pass

func load_scene(path: String):
	if get_child_count() > 0:
		get_child(0).queue_free()
	var scene = load(path)
	add_child(scene.instantiate())
