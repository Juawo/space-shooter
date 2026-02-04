extends Node2D

# Enemies scenes
var enemies: Array[PackedScene] = [
	preload("res://scenes/game/enemies/enemie1/enemie_1.tscn"),
	preload("res://scenes/game/enemies/enemie2/enemie_2.tscn"),
	preload("res://scenes/game/enemies/enemie3/enemie_3.tscn"),
	preload("res://scenes/game/enemies/enemie4/enemie_4.tscn")
]

@onready var enemies_grid: Node2D = $EnemiesGrid
var current_wave : int = 1

func _ready() -> void:
	generate_grid(3,3)
	randomize()

func start_new_wave():
	current_wave += 1
	var cols = 3 + floor(current_wave / 2.0)
	var rows = 2 + floor(current_wave / 3.0)
	
	cols = clamp(cols,3,6)
	rows = clamp(rows,2,5)
	
	generate_grid(cols, rows)

func generate_grid(collum_num : int, row_num : int):
	for n in enemies_grid.get_children() :
		n.queue_free()

	var spacing_x = 80
	var spacing_y = 80
	
	#var grid_width = (collum_num - 1) * spacing_x
	
	var start_x = 0 #(get_viewport_rect().size.x - grid_width) / 2
	var start_y = 50
	
	for row in range(row_num) :
		for collum in range(collum_num):
			var enemy = get_random_enemy().instantiate()
			var pos_x = start_x + (collum * spacing_x + spacing_x)
			var pos_y = start_y + (row * spacing_y)
			enemy.position = Vector2(pos_x, pos_y)
			enemies_grid.add_child(enemy)
			enemy.connect("enemy_died", _on_enemy_killed)

func get_random_enemy() -> PackedScene:
	var roll = randi() % 100
	
	# Waves multiplas de 5
	
	if current_wave % 5 == 0:
		if roll < 50 : return enemies[3]
		if roll < 80 : return enemies[2]
		return enemies[1] 
	if current_wave < 3 : 
		if roll < 85 : return enemies[0]
		return enemies[1]
	elif current_wave < 7 :
		if roll < 60 : return enemies[0]
		if roll < 90 : return enemies[1]
		return enemies[2]
	else:
		if roll < 30: return enemies[0]
		if roll < 60: return enemies[1]
		if roll < 85: return enemies[2]
		return enemies[3]
		
func _on_enemy_killed():
	# O sinal é emitido ANTES do queue_free terminar, 
	# então checamos se resta apenas 1 (o que está morrendo agora)
	print("sinal emitido")
	print(enemies_grid.get_child_count())
	
	if enemies_grid.get_child_count() <= 1:
		print(enemies_grid.get_child_count())
		print("Wave finalizada!")
		# Aguarda um tempinho para não brotar a próxima wave na cara do player
		await get_tree().create_timer(1.5).timeout
		start_new_wave()
