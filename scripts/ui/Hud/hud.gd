extends Control

@onready var combo_value: Label = $MarginContainer/VBoxContainer/ScoreLife/ComboValue
@onready var distance_value: Label = $MarginContainer/VBoxContainer/ScoreLife/DistanceValue
@onready var score_value: Label = $MarginContainer/VBoxContainer/ScoreLife/ScoreValue
@onready var life_hud: HBoxContainer = $MarginContainer/VBoxContainer/ScoreLife/LifeHud
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var is_showing : bool = false

func _ready() -> void:
	SessionState.value_changed.connect(update_hud)
	SessionState.combo_changed.connect(_on_combo_changed)
	SessionState.distance_changed.connect(_on_distance_changed)

func show_hud():
	is_showing = true
	visible = true
	animation_player.play("show_hud")

func hide_hud():
	is_showing = false
	animation_player.play_backwards("show_hud")
	await animation_player.animation_finished
	visible = is_showing
	GameEvents.hud_closed.emit()

func update_hud(score : int) -> void:
	score_value.text = str(score)

func _on_combo_changed(value : float) -> void:
	combo_value.text = "%.1fx" % value

func _on_distance_changed(value : float) -> void:
	distance_value.text = str(value) + "m"

func _on_button_pressed() -> void:
	SoundManager.play_click()
	GameEvents.pause_requested.emit()

func reset_life():
	var lifes = life_hud.get_children()
	for life in lifes :
		life.modulate.a = 1.0
		life.visible = true

func update_life(life_value : int):
	var lifes = life_hud.get_children()
	if life_value < lifes.size():
		animate_life(lifes[life_value])

func animate_life(life_node : TextureRect):
	var tween = create_tween()
	
	for i in range(2):
		tween.tween_property(life_node, "modulate:a", 0.0, 0.1) # a = alpha (transparência)
		tween.tween_property(life_node, "modulate:a", 1.0, 0.1)
	
	tween.tween_property(life_node, "modulate:a", 0.0, 0.2)
	tween.finished.connect(func(): life_node.visible = false)
