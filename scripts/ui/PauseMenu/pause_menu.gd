extends Control

@onready var high_score_value: Label = $Panel/MarginContainer/VBoxContainer/Scores/HighScore/HighScoreValue
@onready var current_score_value: Label = $Panel/MarginContainer/VBoxContainer/Scores/CurrentScore/CurrentScoreValue
var is_showing : bool = false

func show_pause_menu():
	is_showing = true
	visible = is_showing
	high_score_value.text = str(SessionState.high_score)
	current_score_value.text = str(SessionState.current_score)

func hide_pause_menu():
	is_showing = false
	visible = is_showing

func _on_home_button_pressed() -> void:
	GameEvents.main_menu_requested.emit()

func _on_resume_button_pressed() -> void:
	GameEvents.resume_requested.emit()
