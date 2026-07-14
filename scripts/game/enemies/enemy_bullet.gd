extends Area2D

@export var BULLET_SPEED := 250
@export var damage_value := 1

func _process(delta: float) -> void:
	# Fica descendo
	position.y += BULLET_SPEED * delta

func explode() -> void :
	SoundManager.play_impact_plasma()
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
