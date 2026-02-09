extends Node2D

@onready var hud: Control = $Hud
@onready var player: CharacterBody2D = $Player
@onready var enemies_spawner: Node2D = $EnemiesSpawner

func _ready() -> void:
	player.life_change.connect(hud.update_life)

func hide_hud():
	hud.hide_hud()

func show_hud():
	hud.show_hud()

func reset_game():
	clean_world()
	reset_player()
	player.playerLife = 3
	SessionState.current_score = 0
	enemies_spawner.reset_spawner()
	hud.reset_life()

func clean_world():
	var entities_to_clear = get_tree().get_nodes_in_group("Enemies") \
	+ get_tree().get_nodes_in_group("EnemiesProjectiles") +  \
	get_tree().get_nodes_in_group("PlayerProjectiles")
	print("Inimigos encontrados para limpar: ", get_tree().get_nodes_in_group("Enemies").size())
	for entity in entities_to_clear:
		entity.queue_free()

func reset_player():
	if player:
		# Posição instantânea para não bugar o reinício
		player.global_position = Vector2(204.0, 840.0) 
		player.velocity = Vector2.ZERO # Zere a velocidade para ele não "drifar"
