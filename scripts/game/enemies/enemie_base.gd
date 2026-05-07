extends Area2D

signal enemy_died
# TODO : Emitir score_value quando eliminado!

@export var power_up_scene := preload("res://scenes/game/upgrades/cadence.tscn")
@export_range(1, 4) var enemy_level := 1 # Nível de dificuldade (1 a 4)

@export var life := 1
@export var SPEED := 60
@export var score_value := 10
@export var can_shoot := false
@export var base_color := Color.CHARTREUSE

@onready var particle_die: CPUParticles2D = $ParticleDie
@onready var shoot_timer: Timer = $ShootTimer
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	if can_shoot:
		shoot_timer.start(randf_range(1.5,3.0))
		# Randomizando momento de disparar de cada inimigo
		shoot_timer.wait_time = randf_range(1.5,3.0)
	else :
		# Ja que o inimigo nao atira, removo o timer
		shoot_timer.queue_free()
	
	particle_die.color = base_color

func _process(delta: float) -> void:
	position.y += SPEED * delta

func takeDamage(damage_value: int) -> void:
	life -= damage_value
	if(life <= 0):
		die()

func dieTween() -> Tween:
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(7.5, 7.5), 0.4)
	return tween

func die():
	SessionState.current_score += score_value
	
	check_drop_chance()
	
	# Desativando as fisicas do inimigo
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	# Parando de "atirar"
	if can_shoot:
		shoot_timer.paused = true
	
	# Toca o Tween para aumentar o inimigo antes de morrer
	await dieTween().finished
	
	# Esconde o sprite para tocar so as particulas
	sprite_2d.visible = false
	
	# Dispara particula de explodir
	particle_die.emitting = true
	
	# Espera as particulas encerrarem para liberar da memoria
	await particle_die.finished
	enemy_died.emit()
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if(area.is_in_group("PlayerProjectiles")):
		takeDamage(area.damage_value)
		area.queue_free()

func shoot():
	# logica de disparo, implementado nas scenes filhos
	pass

func _on_shoot_timer_timeout() -> void:
	# Dispara quando o tempo de "cooldown" encerrar
	shoot()

# Caso o inimigo saia do range da tela, ele e eliminado, para evitar processamento desnecessario
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

# --- Função de Drop Baseada em Nível ---
func check_drop_chance():
	# Define a chance base (ex: Nível 1 = 5%, Nível 4 = 20%)
	var drop_probability = enemy_level * 50
	var random_value = randi() % 100 # Gera um número entre 0 e 99
	
	if random_value < drop_probability:
		spawn_power_up()
		
func spawn_power_up():
	if power_up_scene:
		var p_up = power_up_scene.instantiate()
		p_up.global_position = global_position
		# Adiciona o item à cena principal para ele não sumir com o inimigo
		get_tree().current_scene.add_child(p_up)
