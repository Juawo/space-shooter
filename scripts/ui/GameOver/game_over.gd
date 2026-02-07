extends Control

@onready var high_score_value: Label = $Panel/MarginContainer/VBoxContainer/Scores/HighScore/HighScoreValue
@onready var current_score_value: Label = $Panel/MarginContainer/VBoxContainer/Scores/CurrentScore/CurrentScoreValue
var is_showing : bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func show_game_over():
	is_showing = true
	visible = is_showing
	animation_player.play("show_game_over")
	high_score_value.text = str(SessionState.high_score)
	current_score_value.text = str(SessionState.current_score)

func hide_game_over():
	is_showing = false
	animation_player.play_backwards("show_game_over")
	await animation_player.animation_finished
	visible = is_showing

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		show_game_over()
	if event is InputEventMouseButton:
		hide_game_over()
