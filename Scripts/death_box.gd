extends Area2D

signal death


<<<<<<< HEAD
# this is just a proof of concept for Thing That Kills You - you can replace/delete
# when we start Doing Things

func _on_area_entered(_area: Area2D) -> void:
	#print("death box entered")
	death.emit() 
=======


func _on_area_entered(area: Area2D) -> void:
	print("death box entered")
	death.emit() # Replace with function body.
>>>>>>> 4ca1aa36e63c707fba929dfdc04ae0af7383b64b
