extends Area2D

@export var bullet_speed := 250
@export var damage_value := 1

func _process(delta: float) -> void:
	position.y -= bullet_speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
