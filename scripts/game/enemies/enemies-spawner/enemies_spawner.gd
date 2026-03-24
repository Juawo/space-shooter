extends Node2D


# Referências das cenas dos inimigos
var enemies: Array[PackedScene] = [
	preload("res://scenes/game/enemies/enemie1/enemie_1.tscn"),
	preload("res://scenes/game/enemies/enemie2/enemie_2.tscn"),
	preload("res://scenes/game/enemies/enemie3/enemie_3.tscn"),
	preload("res://scenes/game/enemies/enemie4/enemie_4.tscn")
]

@onready var dificult_timer: Timer = $DificultTimer
@onready var spawn_timer: Timer = $SpawnTimer # Adicione um Timer como filho do Spawner no editor
@onready var screen_width = get_viewport_rect().size.x
var current_wave : int = 1

func _ready() -> void:
	randomize()

func spawn_enemy():
	# Escolhe o inimigo baseado na probabilidade que você já criou
	var enemy_scene = get_random_enemy()
	var enemy = enemy_scene.instantiate()
	
	# Posição X aleatória dentro da tela, com uma margem de 50px para não nascer colado na borda
	var random_x = randf_range(50, screen_width - 50)
	# Nasce um pouco acima da tela (Y negativo) para não "brotar" do nada
	enemy.global_position = Vector2(random_x, 20)
	
	get_tree().current_scene.add_child(enemy)

func get_random_enemy() -> PackedScene:
	# Sua lógica de probabilidade que já estava funcionando
	var roll = randi() % 100
	
	if current_wave % 5 == 0:
		if roll < 50: return enemies[3]
		if roll < 80: return enemies[2]
		return enemies[1]
	
	if current_wave < 3:
		if roll < 85: return enemies[0]
		return enemies[1]
	elif current_wave < 7:
		if roll < 60: return enemies[0]
		if roll < 90: return enemies[1]
		return enemies[2]
	else:
		if roll < 30: return enemies[0]
		if roll < 60: return enemies[1]
		if roll < 85: return enemies[2]
		return enemies[3]


func _on_spawn_timer_timeout() -> void:
	spawn_enemy()

func _on_dificult_timer_timeout() -> void:
	current_wave += 1
	# Dica extra: acelerar o spawn conforme a wave sobe
	spawn_timer.wait_time = max(0.5, spawn_timer.wait_time - 0.1)

func reset_spawner():
	current_wave = 1
	spawn_timer.wait_time = 2
