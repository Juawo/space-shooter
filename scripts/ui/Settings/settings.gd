extends Control

enum Controls { TILT, TOUCH }
var volume : float = 100.0
var language : int
var controlMode : Controls = Controls.TILT

var main_scene : PackedScene = preload("res://scenes/game/main.tscn")

@onready var sound_value: Label = $VBoxContainer/ContentSettings/VBoxContainer/Panel/MarginContainer/VBoxContainer/Sound/SoundContainer/SoundValue
@onready var language_option: OptionButton = $VBoxContainer/ContentSettings/VBoxContainer/Panel/MarginContainer/VBoxContainer/Language/LanguageOption
@onready var tilt_button: Button = $VBoxContainer/ContentSettings/VBoxContainer/Panel/MarginContainer/VBoxContainer/Controls/ControlsOptions/TiltButton
@onready var touch_button: Button = $VBoxContainer/ContentSettings/VBoxContainer/Panel/MarginContainer/VBoxContainer/Controls/ControlsOptions/TouchButton
@onready var sound_slider: HSlider = $VBoxContainer/ContentSettings/VBoxContainer/Panel/MarginContainer/VBoxContainer/Sound/SoundContainer/SoundSlider
@onready var nickname: Label = $VBoxContainer/Header/HBoxContainer/HBoxContainer/Nickname

func _ready() -> void:
	nickname.text = SaveManager.player_nickname
	volume = SaveManager.volume
	controlMode = SaveManager.control_mode as Controls
	language = SaveManager.language
	tilt_button.button_pressed = (controlMode == Controls.TILT)
	touch_button.button_pressed = (controlMode == Controls.TOUCH)
	language_option.select(language)
	sound_slider.value = volume
	
	
func _on_sound_slider_value_changed(value: float) -> void:
	sound_value.text = str(int(value)) + "%"
	volume = value

func _on_language_option_item_selected(index: int) -> void:
	language = index

func _on_button_pressed() -> void:
	SaveManager.volume = volume
	SaveManager.language = language
	SaveManager.control_mode = controlMode
	SaveManager.save_data()
	
	get_tree().change_scene_to_packed(main_scene)

func _on_tilt_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		controlMode = Controls.TILT

func _on_touch_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		controlMode = Controls.TOUCH
