extends Control

enum Controls { TILT, TOUCH }
var music_volume : float = 100.0
var sfx_volume : float = 100.0
var sensibility : float = 100.0
var controlMode : Controls = Controls.TILT

var main_scene : PackedScene = preload("res://scenes/game/main.tscn")
var update_nickname_scene : PackedScene = preload("res://scenes/ui/Settings/nickname_update_panel.tscn")

@onready var music_slider: HSlider = $VBoxContainer/ContentSettings/VBoxContainer/Panel/MarginContainer/VBoxContainer/Sound/SoundContainer/MusicSlider
@onready var music_value: Label = $VBoxContainer/ContentSettings/VBoxContainer/Panel/MarginContainer/VBoxContainer/Sound/SoundContainer/MusicValue

@onready var sfx_value: Label = $VBoxContainer/ContentSettings/VBoxContainer/Panel/MarginContainer/VBoxContainer/Sound/SFXContainer2/SFXValue
@onready var sfx_slider: HSlider = $VBoxContainer/ContentSettings/VBoxContainer/Panel/MarginContainer/VBoxContainer/Sound/SFXContainer2/SFXSlider

@onready var sensibilityt_slider: HSlider = $VBoxContainer/ContentSettings/VBoxContainer/Panel/MarginContainer/VBoxContainer/Sensibility/SensibilityContainer/SensibilitytSlider
@onready var sensibility_value: Label = $VBoxContainer/ContentSettings/VBoxContainer/Panel/MarginContainer/VBoxContainer/Sensibility/SensibilityContainer/SensibilityValue

@onready var tilt_button: Button = $VBoxContainer/ContentSettings/VBoxContainer/Panel/MarginContainer/VBoxContainer/Controls/ControlsOptions/TiltButton
@onready var touch_button: Button = $VBoxContainer/ContentSettings/VBoxContainer/Panel/MarginContainer/VBoxContainer/Controls/ControlsOptions/TouchButton
@onready var nickname: Label = $VBoxContainer/Header/HBoxContainer/HBoxContainer/Nickname
@onready var version: Label = $VBoxContainer/ContentSettings/VBoxContainer/version

# TODO : Alterar nickname para o novo, caso tenha alterado
func _ready() -> void:
	nickname.text = SaveManager.player_nickname
	
	music_volume = SaveManager.music_volume
	sfx_volume = SaveManager.sfx_volume
	
	music_slider.value = music_volume
	sfx_slider.value = sfx_volume
	
	sensibility = SaveManager.sensibility
	sensibilityt_slider.value = sensibility

	controlMode = SaveManager.control_mode as Controls
	tilt_button.button_pressed = (controlMode == Controls.TILT)
	touch_button.button_pressed = (controlMode == Controls.TOUCH)

func _on_button_pressed() -> void:
	SoundManager.play_click()
	SaveManager.music_volume = music_volume
	SaveManager.sfx_volume = sfx_volume
	SaveManager.control_mode = controlMode
	SaveManager.sensibility = sensibility
	SaveManager.save_data()
	
	get_tree().change_scene_to_packed(main_scene)

func _on_tilt_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		controlMode = Controls.TILT
		SoundManager.play_click()

func _on_touch_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		controlMode = Controls.TOUCH
		SoundManager.play_click()

var old_sense_value := 0.0
func _on_sensibilityt_slider_value_changed(value: float) -> void:
	sensibility = value
	sensibility_value.text = str(int(value/2)) + "%"
	if value >= old_sense_value :
		SoundManager.play_scroll(true)
	else :
		SoundManager.play_scroll(false)
	old_sense_value = value

func _on_change_button_pressed() -> void:
	SoundManager.play_click()
	var scene = update_nickname_scene.instantiate()
	scene.position = Vector2(0,20)
	add_child(scene)
	scene.nickname_changed.connect(_on_nickname_changed)
	
func _on_nickname_changed(new_nickname : String) -> void :
	nickname.text = new_nickname
	SoundManager.play_impact()
	
var old_sfx_value := 0.0
func _on_sfx_slider_value_changed(value: float) -> void:
	sfx_value.text = str(int(value)) + "%"
	sfx_volume = value
	SoundManager.update_sfx_volume(sfx_volume)
	if value >= old_sfx_value :
		SoundManager.play_scroll(true)
	else :
		SoundManager.play_scroll(false)
	old_sfx_value = value

var old_music_value := 0.0
func _on_music_slider_value_changed(value: float) -> void:
	music_value.text = str(int(value)) + "%"
	music_volume = value
	SoundManager.update_music_volume(music_volume)
	if value >= old_music_value :
		SoundManager.play_scroll(true)
	else :
		SoundManager.play_scroll(false)
	old_music_value = value
	
