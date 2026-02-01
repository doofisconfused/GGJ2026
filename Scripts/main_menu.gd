extends Control



func _on_play_pressed() -> void:
	Global.fade.load_loc = "res://Scenes/tutorial.tscn"
	Global.fade.fade_out()

func _on_exit_pressed() -> void:
	get_tree().quit()
