extends Node2D

class_name Chicken

@export var level_to_load : String = ""

var can_eat : bool = false
var dead : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.chicken = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !$AnimationPlayer.is_playing() and global_position.distance_to(Global.player.global_position) < 500:
		$AnimationPlayer.play("panic")
	
func eat() -> void:
	if can_eat and !dead:
		dead = true
		$GPUParticles2D.global_position = $ChickenChill.global_position
		$GPUParticles2D.restart()
		$ChickenChill.visible = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	can_eat = true
	$Label.visible = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	can_eat = false
	$Label.visible = false


func _on_gpu_particles_2d_finished() -> void:
	Global.fade.load_loc = level_to_load
	Global.fade.fade_out()
