extends Area2D


func _on_area_entered(area: Area2D) -> void:
	$AnimationPlayer.play("bounce")
	$AudioStreamPlayer.play()
	$GPUParticles2D.restart()
