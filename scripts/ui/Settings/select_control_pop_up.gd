extends Control

enum Controls { TILT, TOUCH }

var control_mode : Controls
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var tilt_button: Button = $MarginContainer/Control/Panel/MarginContainer/Controls/ControlsOptions/TiltButton
@onready var touch_button: Button = $MarginContainer/Control/Panel/MarginContainer/Controls/ControlsOptions/TouchButton

func _ready() -> void:
	animation_player.play_backwards("open_pop_up")

func _on_tilt_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		control_mode = Controls.TILT
		SaveManager.control_mode = control_mode
	finalize_selection()

func _on_touch_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		control_mode = Controls.TOUCH
		SaveManager.control_mode = control_mode
	finalize_selection()
	

func finalize_selection() -> void :
	tilt_button.disabled = true
	touch_button.disabled = true
	SaveManager.has_chosen_control = true 
	SaveManager.save_data()
	await get_tree().create_timer(0.6).timeout
	animation_player.play("open_pop_up")
	await animation_player.animation_finished
	queue_free()
