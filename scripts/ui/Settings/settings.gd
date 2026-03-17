extends Control

enum Controls { TILT, TOUTCH }
var volume : float = 100.0
var language : String
var controlMode : Controls = Controls.TILT

var main_scene : PackedScene = preload("res://scenes/game/main.tscn")

@onready var sound_value: Label = $VBoxContainer/ContentSettings/VBoxContainer/Panel/MarginContainer/VBoxContainer/Sound/SoundContainer/SoundValue
@onready var language_option: OptionButton = $VBoxContainer/ContentSettings/VBoxContainer/Panel/MarginContainer/VBoxContainer/Language/LanguageOption
@onready var tilt_button: Button = $VBoxContainer/ContentSettings/VBoxContainer/Panel/MarginContainer/VBoxContainer/Controls/ControlsOptions/TiltButton
@onready var touch_button: Button = $VBoxContainer/ContentSettings/VBoxContainer/Panel/MarginContainer/VBoxContainer/Controls/ControlsOptions/ToutchButton

func _ready() -> void:
	if controlMode == Controls.TILT:
		tilt_button.button_pressed = true
	else:
		touch_button.button_pressed = true
	language = language_option.get_item_text(language_option.selected)

func _on_sound_slider_value_changed(value: float) -> void:
	sound_value.text = str(int(value)) + "%"
	volume = value

func _on_language_option_item_selected(index: int) -> void:
	language = language_option.get_item_text(index)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_scene)

func _on_tilt_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		controlMode = Controls.TILT

func _on_touch_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		controlMode = Controls.TOUTCH
