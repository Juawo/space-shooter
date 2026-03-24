extends Control


@onready var v_box_container: VBoxContainer = $MarginContainer/Panel/MarginContainer/VBoxContainer
@onready var nickname_input: LineEdit = $MarginContainer/Panel/MarginContainer/VBoxContainer/Nickname/NicknameInput
@onready var country_input: LineEdit = $MarginContainer/Panel/MarginContainer/VBoxContainer/Country/CountryInput
@onready var age_input: HSlider = $MarginContainer/Panel/MarginContainer/VBoxContainer/Age/AgeInput
@onready var age_value: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/Age/AgeValue

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var feedback: Label = $MarginContainer/Panel/MarginContainer/Feedback

@onready var timer: Timer = $Timer

func _ready() -> void:
	ApiManager.play_registered.connect(register_feedback) 
	# TODO : Conferir a transferencia dos dados do sinal aqui

func _on_h_slider_value_changed(value: float) -> void:
	age_value.text = str(int(value))
	
func _on_button_pressed() -> void:
	var player_data = {
		"Nickname" : nickname_input.text,
		"Country" : country_input.text,
		"Age" : int(age_input.value)
	}
	ApiManager.register_player(player_data)
	print(player_data)

func register_feedback(is_registered : bool):
	if is_registered:
		v_box_container.visible = false
		feedback.visible = true
		timer.start(2)
		await timer.timeout
		animation_player.play("close_register")
		await animation_player.animation_finished
		self.queue_free()
	else :
		feedback.text = "Registration error, your high score will not be saved on the server."
		v_box_container.visible = false
		feedback.visible = true
		timer.start(2)
		await timer.timeout
		animation_player.play("close_register")
		await animation_player.animation_finished
		self.queue_free()
