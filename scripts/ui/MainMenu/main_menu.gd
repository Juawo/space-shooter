extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var showing: bool = false
@onready var background_tap_area: Button = $BackgroundTapArea
@onready var score_value_label: Label = $MarginContainer/VBoxContainer/HeaderWrapper/Header/HighScoreLabel/ScoreValueLabel

func _ready() -> void:
	SessionState.high_score_changed.connect(_on_high_score_changed)
	score_value_label.text = str(SessionState.high_score)

func _on_high_score_changed(high_score_value : int):
	score_value_label.text = str(high_score_value)
	
func hideMainMenu():
	background_tap_area.disabled = true
	animation_player.play("hide_menu")
	showing = false
	await animation_player.animation_finished
	self.visible = false
	
func showMainMenu():
	self.visible = true
	animation_player.play_backwards("hide_menu")
	await animation_player.animation_finished
	animation_player.play("idle")
	showing = true
	background_tap_area.disabled = false

func _on_background_tap_area_pressed() -> void:
	if is_visible_in_tree():
		GameEvents.game_requested.emit()
