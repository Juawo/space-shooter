extends Area2D

@export var life := 1
@export var score_value := 10
@export var can_shoot := false

func takeDamage():
	life -= 1
	if(life == 0):
		die()

func die():
	queue_free()
