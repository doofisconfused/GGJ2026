extends Control

class_name Fade

var load_loc : String = ""

func _ready() -> void:
	Global.fade = self
	fade_in()
	
func fade_in() -> void:
	$AnimationPlayer.play("fade_in")

func fade_out() -> void:
	$AnimationPlayer.play("fade_out")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out" and load_loc != "":
		SceneManager.load_scene(load_loc)
		load_loc = ""
