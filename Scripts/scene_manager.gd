extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_scene("res://Scenes/level_1.tscn")

func load_scene(path: String):
	if get_child_count() > 0:
		get_child(0).queue_free()
	var scene = load(path)
	add_child(scene.instantiate())
	
	if Global.fade:
		Global.fade.fade_in()
