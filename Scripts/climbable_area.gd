extends Area2D

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		area.get_parent().can_climb = true


func _on_area_exited(area: Area2D) -> void:
	if area.get_parent() is Player:
		area.get_parent().can_climb = false
