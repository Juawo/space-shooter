extends Area2D

@export var BULLET_SPEED := 250
@export var damage_value := 1

func _process(delta: float) -> void:
	# Fica descendo
	position.y += BULLET_SPEED * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Limpa da memoria o tiro, se ele nao e mais visivel
	queue_free()
