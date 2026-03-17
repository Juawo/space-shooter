extends Node

signal pause_requested
signal resume_requested
signal main_menu_requested
signal game_over
signal game_requested
signal hud_closed

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
