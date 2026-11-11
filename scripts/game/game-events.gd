extends Node

# Game state signals
signal pause_requested
signal resume_requested
signal main_menu_requested
signal game_over
signal game_requested
signal hud_closed

# Run signals
signal enemy_spawned
signal enemy_died(score_value : int)
signal enemy_escaped

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
