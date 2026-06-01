extends Node2D

# Referências das cenas dos inimigos
var enemies: Array[PackedScene] = [
	preload("res://scenes/game/enemies/enemie1/enemie_1.tscn"),
	preload("res://scenes/game/enemies/enemie2/enemie_2.tscn"),
	preload("res://scenes/game/enemies/enemie3/enemie_3.tscn"),
	preload("res://scenes/game/enemies/enemie4/enemie_4.tscn")
]

@onready var dificult_timer: Timer = $DificultTimer
@onready var spawn_timer: Timer = $SpawnTimer 
@onready var screen_width = get_viewport_rect().size.x

var current_wave : int = 1

func _ready() -> void:
	randomize()
	reset_spawner() # Garante que inicia com os valores dinâmicos corretos

func spawn_enemy():
	var enemy_scene = get_random_enemy()
	var enemy = enemy_scene.instantiate()
	
	var random_x = randf_range(50, screen_width - 50)
	enemy.global_position = Vector2(random_x, -20) # Y negativo para nascer fora da tela!
	
	get_tree().current_scene.add_child(enemy)

# ─── 🌟 A NOVIDADE: GERADOR DE BANDOS (SQUADS) ───
func trigger_wave_spawn():
	# Define quantos inimigos vão nascer neste pulso do timer
	var spawn_count = 1
	var roll = randi() % 100
	
	# Nas primeiras waves, tem 25% de chance de nascer em dupla
	if current_wave < 3:
		if roll < 25: spawn_count = 2
	# Nas waves do meio, pode nascer até 3 juntos
	elif current_wave < 7:
		if roll < 35: spawn_count = 2
		elif roll < 50: spawn_count = 3
	# Nas mais avançadas, o bicho pega: hordas de até 4 de uma vez
	else:
		if roll < 40: spawn_count = 2
		elif roll < 65: spawn_count = 3
		elif roll < 80: spawn_count = 4

	# Instancia a quantidade sorteada com um micro delay ou posições separadas
	for i in range(spawn_count):
		spawn_enemy()
		# Se nascer mais de um, dá um leve tempo para não nascerem exatamente no mesmo frame
		if spawn_count > 1:
			await get_tree().create_timer(0.15).timeout

func get_random_enemy() -> PackedScene:
	var roll = randi() % 100
	
	if current_wave % 5 == 0:
		if roll < 50: return enemies[3]
		if roll < 80: return enemies[2]
		return enemies[1]
	
	if current_wave < 3:
		if roll < 75: return enemies[0] # Aumentei chance do inimigo 2 aparecer mais cedo
		return enemies[1]
	elif current_wave < 7:
		if roll < 50: return enemies[0]
		if roll < 85: return enemies[1]
		return enemies[2]
	else:
		if roll < 25: return enemies[0]
		if roll < 50: return enemies[1]
		if roll < 75: return enemies[2]
		return enemies[3]

# ─── ⏱️ TIMERS E PROGRESSÃO ───

func _on_spawn_timer_timeout() -> void:
	trigger_wave_spawn() # Agora chama a lógica com chance de horda

func _on_dificult_timer_timeout() -> void:
	current_wave += 1
	
	# Aceleração mais agressiva no começo, travando no mínimo de 0.4s
	if current_wave < 5:
		spawn_timer.wait_time = max(0.4, spawn_timer.wait_time - 0.2)
	else:
		spawn_timer.wait_time = max(0.4, spawn_timer.wait_time - 0.05)
		
	print("Wave Atual: ", current_wave, " | Tempo de Spawn: ", spawn_timer.wait_time)

func reset_spawner():
	current_wave = 1
	spawn_timer.wait_time = 1.5 # Começo um pouco mais rápido (antigo era 2.0)
