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
const MAX_WAVE_DIFFICULTY : int = 10 # Teto onde a dificuldade para de subir agressivamente

func _ready() -> void:
	randomize()
	reset_spawner()

func spawn_enemy():
	var enemy_scene = get_random_enemy()
	var enemy = enemy_scene.instantiate()
	
	var random_x = randf_range(50, screen_width - 50)
	enemy.global_position = Vector2(random_x, -20)
	
	get_tree().current_scene.add_child(enemy)

# ─── 🌟 NOVO GERADOR DE BANDOS BALANCEADO ───
func trigger_wave_spawn():
	var spawn_count = 1
	var roll = randi() % 100
	
	# Wave 1 e 2: Praticamente solo, raras duplas
	if current_wave < 3:
		if roll < 15: spawn_count = 2
	# Wave 3 a 5: Introduz duplas e trios raros
	elif current_wave < 6:
		if roll < 30: spawn_count = 2
		elif roll < 40: spawn_count = 3
	# Wave 6 a 9: Mais duplas e trios, quartetos raríssimos
	elif current_wave < 10:
		if roll < 40: spawn_count = 2
		elif roll < 60: spawn_count = 3
		elif roll < 70: spawn_count = 4
	# Wave 10+: Dificuldade máxima controlada (Tetos saudáveis de horda)
	else:
		if roll < 45: spawn_count = 2
		elif roll < 70: spawn_count = 3
		elif roll < 85: spawn_count = 4

	for i in range(spawn_count):
		# Verificação extra: se o timer de spawn estiver muito rápido, 
		# espaçamos um pouco mais o bando para não encavalar inimigos
		var micro_delay = 0.25 if spawn_timer.wait_time < 0.8 else 0.15
		
		spawn_enemy()
		if spawn_count > 1:
			await get_tree().create_timer(micro_delay).timeout

func get_random_enemy() -> PackedScene:
	var roll = randi() % 100
	
	# A cada 5 waves, foca em inimigos mais pesados (Wave de Elite)
	if current_wave % 5 == 0:
		if roll < 40: return enemies[3]
		if roll < 70: return enemies[2]
		return enemies[1]
	
	# --- FASE INICIAL (Waves 1 e 2) ---
	# Foco massivo no Inimigo 1 para gerar volume no começo do jogo
	if current_wave < 3:
		if roll < 80: 
			return enemies[0] # Inimigo 1 (80% de chance - Grande maioria)
		else: 
			return enemies[1] # Inimigo 2 (20% de chance - Raro/Suporte)
			
	# --- FASE INTERMEDIÁRIA (Waves 3 a 5) ---
	# O Inimigo 1 e 2 dividem o espaço, e o Inimigo 3 começa a aparecer
	elif current_wave < 6:
		if roll < 45: return enemies[0]
		elif roll < 80: return enemies[1]
		else: return enemies[2]
		
	# --- LATE GAME (Waves 6+) ---
	# Distribuição equilibrada por toda a frota inimiga
	else:
		if roll < 20: return enemies[0]
		elif roll < 45: return enemies[1]
		elif roll < 75: return enemies[2]
		else: return enemies[3]

func _on_spawn_timer_timeout() -> void:
	trigger_wave_spawn()

func _on_dificult_timer_timeout() -> void:
	# Só aumenta a dificuldade se não tiver atingido o limite máximo
	if current_wave < MAX_WAVE_DIFFICULTY:
		current_wave += 1
		
		# Curva de aceleração suavizada (Mínimo balanceado para 0.75s)
		# Nota: 0.4s gerando bandos de 4 era o que quebrava o jogo.
		if current_wave < 4:
			spawn_timer.wait_time = max(0.75, spawn_timer.wait_time - 0.15)
		else:
			spawn_timer.wait_time = max(0.75, spawn_timer.wait_time - 0.05)
			
		print("Wave Atual: ", current_wave, " | Tempo de Spawn: ", spawn_timer.wait_time)
	else:
		# Opcional: A partir do nível máximo, apenas mude sutilmente o spawn aleatório se quiser,
		# mas mantendo o ritmo para o jogador conseguir respirar.
		print("Dificuldade Máxima Atingida! Ritmo estabilizado.")

func reset_spawner():
	current_wave = 1
	# Alterado de 1.6 para 1.0 ou 0.8. 
	# Quanto menor este número, mais rápido os inimigos surgem no início!
	spawn_timer.wait_time = 0.8
