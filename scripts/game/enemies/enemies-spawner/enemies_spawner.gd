extends Node2D

var enemies: Array[PackedScene] = [
	preload("res://scenes/game/enemies/enemie1/enemie_1.tscn"), # index 0
	preload("res://scenes/game/enemies/enemie2/enemie_2.tscn"), # index 1
	preload("res://scenes/game/enemies/enemie3/enemie_3.tscn"), # index 2
	preload("res://scenes/game/enemies/enemie4/enemie_4.tscn")  # index 3
]

# TABELA DE PROBABILIDADES (A soma de cada array deve ser 100)
# Formato -> Wave: [Chance do Inimigo 1, Inimigo 2, Inimigo 3, Inimigo 4]
const ENEMY_SPAWN_WEIGHTS = {
	1: [90, 10,  0,  0],
	2: [80, 10, 10,  0],
	3: [40, 15, 45,  0],
	4: [30, 20, 40, 10],
	5: [20, 35, 35, 10],
	6: [20, 25, 30, 25]
}

# TABELA DE QUANTIDADE DE SPAWNS (A soma também deve ser 100)
# Formato -> Wave: [Chance de 1 Inimigo, 2 Inimigos, 3 Inimigos, 4 Inimigos]
const SPAWN_COUNT_WEIGHTS = {
	1: [50, 50,  0,  0], # Waves 1 a 3
	4: [30, 40, 30,  0], # Waves 4 a 6
	7: [10, 30, 30, 30]  # Waves 7 em diante
}
@onready var dificult_timer: Timer = $DificultTimer
@onready var spawn_timer: Timer = $SpawnTimer 
@onready var screen_width = get_viewport_rect().size.x

var current_wave : int = 1
const MAX_WAVE_DIFFICULTY : int = 10 
var last_spawn_x : float = 0.0
const MIN_SPAWN_DISTANCE : float = 80.0 

func _ready() -> void:
	randomize()
	reset_spawner()

func reset_spawner():
	current_wave = 1
	spawn_timer.wait_time = 0.8
	spawn_timer.start()
	dificult_timer.start()

func spawn_enemy(offset_y: float = 0.0):
	var enemy_scene = get_random_enemy()
	var enemy = enemy_scene.instantiate()
	
	var random_x = randf_range(50, screen_width - 50)
	
	if abs(random_x - last_spawn_x) < MIN_SPAWN_DISTANCE:
		random_x = fmod(random_x + (screen_width / 2.0), screen_width - 100) + 50
	
	last_spawn_x = random_x
	
	enemy.global_position = Vector2(random_x, -40 - offset_y)
	
	get_tree().current_scene.add_child(enemy)

func trigger_wave_spawn():
	var spawn_count = get_spawn_count()
	
	for i in range(spawn_count):
		var vertical_spacing = i * 70.0 
		spawn_enemy(vertical_spacing)

func _on_spawn_timer_timeout() -> void:
	trigger_wave_spawn()

func _on_dificult_timer_timeout() -> void:
	if current_wave < MAX_WAVE_DIFFICULTY:
		current_wave += 1
		spawn_timer.wait_time = max(0.4, spawn_timer.wait_time - 0.08)
	else:
		print("Dificuldade Máxima! Sobreviva se puder.")

func get_random_enemy() -> PackedScene:
	var wave_key = min(current_wave, 6) 
	var chances = ENEMY_SPAWN_WEIGHTS[wave_key]
	
	var roll = randf() * 100 
	var chance_acumulada = 0.0
	
	for i in range(chances.size()):
		chance_acumulada += chances[i]
		if roll <= chance_acumulada:
			return enemies[i]
			
	return enemies[0]

func get_spawn_count() -> int:
	var wave_key = 1
	if current_wave >= 7: wave_key = 7
	elif current_wave >= 4: wave_key = 4
	
	var chances = SPAWN_COUNT_WEIGHTS[wave_key]
	var roll = randf() * 100
	var chance_acumulada = 0.0
	
	for i in range(chances.size()):
		chance_acumulada += chances[i]
		if roll <= chance_acumulada:
			return i + 1 
			
	return 1
