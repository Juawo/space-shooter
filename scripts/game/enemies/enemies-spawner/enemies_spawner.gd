extends Node2D

# Referências das cenas dos inimigos
var enemies: Array[PackedScene] = [
	preload("res://scenes/game/enemies/enemie1/enemie_1.tscn"), # index 0
	preload("res://scenes/game/enemies/enemie2/enemie_2.tscn"), # index 1
	preload("res://scenes/game/enemies/enemie3/enemie_3.tscn"), # index 2
	preload("res://scenes/game/enemies/enemie4/enemie_4.tscn")  # index 3
]

@onready var dificult_timer: Timer = $DificultTimer
@onready var spawn_timer: Timer = $SpawnTimer 
@onready var screen_width = get_viewport_rect().size.x

var current_wave : int = 1
const MAX_WAVE_DIFFICULTY : int = 10 

# Variável para lembrar onde nasceu o último inimigo e evitar colisões no spawn
var last_spawn_x : float = 0.0
const MIN_SPAWN_DISTANCE : float = 65.0 # Distância horizontal mínima entre inimigos seguidos

func _ready() -> void:
	randomize()
	reset_spawner()

# Modificado para aceitar uma variação de altura (offset_y) opcional
func spawn_enemy(offset_y: float = 0.0):
	var enemy_scene = get_random_enemy()
	var enemy = enemy_scene.instantiate()
	
	var random_x = randf_range(50, screen_width - 50)
	
	# Se o novo X for muito perto do anterior, joga ele para o outro lado da tela
	if abs(random_x - last_spawn_x) < MIN_SPAWN_DISTANCE:
		random_x = fmod(random_x + (screen_width / 2.0), screen_width - 100) + 50
	
	last_spawn_x = random_x
	
	# Aplicamos o offset_y para que inimigos do mesmo bando venham escalonados na vertical
	enemy.global_position = Vector2(random_x, -20 - offset_y)
	
	get_tree().current_scene.add_child(enemy)

# ─── 🌟 GERADOR DE BANDOS COM ARRANJO VERTICAL ───
func trigger_wave_spawn():
	var spawn_count = 1
	var roll = randi() % 100
	
	if current_wave < 3:
		if roll < 40: spawn_count = 2
		elif roll < 55: spawn_count = 3
	elif current_wave < 6:
		if roll < 45: spawn_count = 2
		elif roll < 65: spawn_count = 3
	elif current_wave < 10:
		if roll < 40: spawn_count = 2
		elif roll < 65: spawn_count = 3
		elif roll < 75: spawn_count = 4
	else:
		if roll < 45: spawn_count = 2
		elif roll < 70: spawn_count = 3
		elif roll < 85: spawn_count = 4

	for i in range(spawn_count):
		var micro_delay = 0.25 if spawn_timer.wait_time < 0.8 else 0.15
		
		# Multiplicamos o índice 'i' por 40 para empurrar os próximos inimigos 
		# do mesmo bando mais para cima (fora da tela), criando uma fila
		var vertical_offset = i * 40.0 
		
		spawn_enemy(vertical_offset)
		
		if spawn_count > 1:
			await get_tree().create_timer(micro_delay).timeout

func get_random_enemy() -> PackedScene:
	var roll = randi() % 100
	
	match current_wave:
		1:
			if roll < 90: return enemies[0] 
			else: return enemies[1]         
		2:
			if roll < 80: return enemies[0] 
			elif roll < 90: return enemies[1]
			else: return enemies[2]         
		3:
			if roll < 15: return enemies[1] 
			elif roll < 60: return enemies[2]
			else: return enemies[0]         
		4:
			if roll < 20: return enemies[1]
			elif roll < 60: return enemies[2]
			elif roll < 90: return enemies[0]
			else: return enemies[3]         
		5:
			if roll < 35: return enemies[1] 
			elif roll < 70: return enemies[2]
			elif roll < 80: return enemies[3]
			else: return enemies[0]         
		_:
			if roll < 20: return enemies[0]
			elif roll < 45: return enemies[1]
			elif roll < 75: return enemies[2]
			else: return enemies[3]

# ─── ⏱️ TIMERS E PROGRESSÃO BALANCEADA ───

func _on_spawn_timer_timeout() -> void:
	trigger_wave_spawn()

func _on_dificult_timer_timeout() -> void:
	if current_wave < MAX_WAVE_DIFFICULTY:
		current_wave += 1
		
		if current_wave < 4:
			spawn_timer.wait_time = max(0.75, spawn_timer.wait_time - 0.15)
		else:
			spawn_timer.wait_time = max(0.75, spawn_timer.wait_time - 0.05)
			
		print("Wave Atual: ", current_wave, " | Tempo de Spawn: ", spawn_timer.wait_time)
	else:
		print("Dificuldade Máxima Atingida! Ritmo estabilizado.")

func reset_spawner():
	current_wave = 1
	spawn_timer.wait_time = 1.3
