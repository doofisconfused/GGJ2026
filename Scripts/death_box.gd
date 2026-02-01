extends Area2D

signal death


# this is just a proof of concept for Thing That Kills You - you can replace/delete
# when we start Doing Things

func _on_area_entered(_area: Area2D) -> void:
	#print("death box entered")
	Global.player.death()
