extends Area2D

@export var fall_speed := 250.0

func _process(delta: float) -> void:
	position.y += fall_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		if body.has_method("apply_speed_boost"):
			SoundManager.play_pickup_cadence()
			body.apply_speed_boost(2) 
			queue_free()

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
