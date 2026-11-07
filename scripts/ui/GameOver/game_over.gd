extends Control

@onready var high_score_value: Label = $Panel/MarginContainer/VBoxContainer/Scores/HighScore/HighScoreValue
@onready var current_score_value: Label = $Panel/MarginContainer/VBoxContainer/Scores/CurrentScore/CurrentScoreValue
@onready var rank_label: Label = $Panel/MarginContainer/VBoxContainer/Metrics/HBoxContainer/TotalRank/RankLabel
@onready var combo_field: HBoxContainer = $Panel/MarginContainer/VBoxContainer/Metrics/HBoxContainer/Fields/ComboField
@onready var distance_field: HBoxContainer = $Panel/MarginContainer/VBoxContainer/Metrics/HBoxContainer/Fields/DistanceField
@onready var kill_efficiency_field: HBoxContainer = $Panel/MarginContainer/VBoxContainer/Metrics/HBoxContainer/Fields/KillEfficiencyField

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_showing : bool = false

func populate_game_over_screen(data : Dictionary) -> void :
	print(data)
	current_score_value.text = str(data.total_score)
	rank_label.text = data.total_rank
	distance_field.populate_field(data.distance_points_value, data.distance_rank)
	combo_field.populate_field(data.max_combo_strike_value, data.max_combo_rank)
	kill_efficiency_field.populate_field(data.kill_efficiency_value, data.kill_efficiency_rank)

func show_game_over():
	is_showing = true
	visible = is_showing
	animation_player.play("show_game_over")
	high_score_value.text = str(SessionState.high_score)
	await animation_player.animation_finished
	populate_game_over_screen(SessionState.calculate_score_return())

func hide_game_over():
	is_showing = false
	animation_player.play_backwards("show_game_over")
	await animation_player.animation_finished
	visible = is_showing

func _on_home_button_pressed() -> void:
	GameEvents.main_menu_requested.emit()
