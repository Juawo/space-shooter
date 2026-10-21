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
	# TODO : this is performatic ?
	var entities_to_clear = get_tree().get_nodes_in_group("Enemies") \
	+ get_tree().get_nodes_in_group("EnemiesProjectiles") +  \
	get_tree().get_nodes_in_group("PlayerProjectiles")
	print("Inimigos encontrados para limpar: ", get_tree().get_nodes_in_group("Enemies").size())
	for entity in entities_to_clear:
		entity.queue_free()

func reset_player():
	# TODO : add animation, player coming from bottom of the screen and go to inital position
	if player:
		player.global_position = Vector2(204.0, 840.0) 
		player.velocity = Vector2.ZERO 
		player.remove_powerups()
