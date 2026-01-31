extends Area2D

signal death




func _on_area_entered(area: Area2D) -> void:
	print("death box entered")
	death.emit() # Replace with function body.
