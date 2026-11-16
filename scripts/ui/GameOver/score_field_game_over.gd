extends HBoxContainer

const FIELDS_NAMES = ["Combo Strike", "Distance", "Kill Effiency"]
@onready var title_field: Label = $VBoxContainer/TitleField
@onready var value_field: Label = $VBoxContainer/HBoxContainer/ValueField
@onready var progress_bar: ProgressBar = $VBoxContainer/HBoxContainer/MarginContainer/ProgressBar
@onready var rank_field: Label = $RankField


@export_enum("Combo Strike:0","Distance:1","Kill Effiency:2") var field_name
@export var field_min_value := 0
@export var field_max_value := 100

var current_displayed_score

func populate_field(field_value, field_rank: String) -> void :
	title_field.text = FIELDS_NAMES[field_name]
	value_field.text = str(field_value)
	rank_field.text = field_rank
	progress_bar.max_value = field_max_value
	progress_bar.min_value = field_min_value
	fill_progress_bar_animation(field_value)

func animate_score_counter(target_score : int, duration : float) -> void :
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_method(_update_score_text, current_displayed_score, target_score, duration)
	var text_tween = create_tween()
	text_tween.tween_property(value_field, "scale", Vector2(1.2,1.2), 0.1)
	text_tween.tween_property(value_field, "scale", Vector2(1.0,1.0), 0.1)
	current_displayed_score = target_score

func _update_score_text(value) -> void :
	value_field.text = str(value)

func fill_progress_bar_animation(value) -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(progress_bar, "value", value, 1.5)
