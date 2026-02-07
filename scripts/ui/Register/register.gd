extends Control

@onready var age_value: Label = $Panel/MarginContainer/VBoxContainer/Age/AgeValue
@onready var age_input = $Panel/MarginContainer/VBoxContainer/Age/AgeInput
@onready var country_input: LineEdit = $Panel/MarginContainer/VBoxContainer/Country/CountryInput
@onready var nickname_input: LineEdit = $Panel/MarginContainer/VBoxContainer/Nickname/NicknameInput
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	ApiManager.play_registered.connect(register_feedback) 
	# TODO : Conferir a transferencia dos dados do sinal aqui

func _on_h_slider_value_changed(value: float) -> void:
	age_value.text = str(int(value))
	
func _on_button_pressed() -> void:
	var player_data = {
		"nickname" : nickname_input.text,
		"country" : country_input.text,
		"age" : age_input.value
	}
	ApiManager.register_player(player_data)

func register_feedback(is_registered : bool):
	if is_registered:
		pass
		# TODO : TERMINAR AQ, RETORNO SOBRE CADASTRO
