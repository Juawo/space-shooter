extends Area2D

@export var life := 1
@export var score_value := 10
@export var can_shoot := false
@export var base_color := Color.CHARTREUSE
@onready var particle_die: CPUParticles2D = $ParticleDie

func _ready() -> void:
	particle_die.color = base_color
	
func takeDamage(damage_value: int) -> void:
	life -= damage_value
	if(life <= 0):
		die()

func die():
	particle_die.emitting = true
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if(area.is_in_group("PlayerProjectiles")):
		takeDamage(area.damage_value)
