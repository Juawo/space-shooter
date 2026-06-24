extends "res://scripts/game/enemies/enemy_bullet.gd"

var velocity_vector := Vector2.ZERO

func _ready() -> void:
	BULLET_SPEED = 300
	velocity_vector =  Vector2.DOWN.rotated(rotation) * BULLET_SPEED

func _process(delta: float) -> void:
	# Fica descendo
	position +=  velocity_vector * delta
