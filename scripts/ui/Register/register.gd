extends Control

@onready var v_box_container: VBoxContainer = $MarginContainer/Panel/MarginContainer/VBoxContainer

@onready var nickname_input: LineEdit = $MarginContainer/Panel/MarginContainer/VBoxContainer/Nickname/nickname_type/nickname_input
@onready var char_count: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/Nickname/nickname_type/char_count
@onready var nickname_feedback: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/Nickname/nicknameFeedback

@onready var country_input: LineEdit = $MarginContainer/Panel/MarginContainer/VBoxContainer/Country/CountryInput
@onready var country_feedback: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/Country/CountryFeedback

@onready var age_input: HSlider = $MarginContainer/Panel/MarginContainer/VBoxContainer/Age/AgeInput
@onready var age_value: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/Age/AgeValue

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var feedback: Label = $MarginContainer/Panel/MarginContainer/Feedback

@onready var detail_return: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/detail_return

@onready var register_btn: Button = $MarginContainer/Panel/MarginContainer/VBoxContainer/register_btn

@onready var timer: Timer = $Timer

func _ready() -> void:
	ApiManager.play_registered.connect(update_interface_by_response_code_return)

func _on_button_pressed() -> void:
	if !validate_country(country_input.text) or !validate_nickname(nickname_input.text):
		return
		
	var player_data = {
		"Nickname" : nickname_input.text,
		"Country" : country_input.text,
		"Age" : int(age_input.value)
	}
	ApiManager.register_player(player_data)
	
	nickname_input.editable = false
	country_input.editable = false
	
	detail_return.text = "Awaiting server response..."
	detail_return.add_theme_color_override("font_color", "#ffff")

func update_interface_by_response_code_return(registered,response_code) -> void :
	
	match response_code:
		201 : 
			detail_return.text = "Player Registered!"
			detail_return.add_theme_color_override("font_color", "#00c805")
			timer.start(2)
			await timer.timeout
			animation_player.play("close_register")
			await animation_player.animation_finished
			queue_free()
		409 : 
			detail_return.text = "Another player has this nickname."
			detail_return.add_theme_color_override("font_color", "#d49a3d")
		400 :
			detail_return.text = "Validation error, check your info."
			detail_return.add_theme_color_override("font_color", "#d4293d")
		500 :
			detail_return.text = "Error in the server side."
			detail_return.add_theme_color_override("font_color", "#d4293d")
		_:
			detail_return.text = "Type your info for register."
			detail_return.add_theme_color_override("font_color", "#ffffff")
	nickname_input.editable = true
	country_input.editable = true
	return

func update_register_btn(is_activated : bool) -> void :
	register_btn.disabled = !is_activated 

func _on_h_slider_value_changed(value: float) -> void:
	age_value.text = str(int(value))

func _on_nickname_input_text_changed(new_text: String) -> void:
	update_counter(new_text)
	var is_nickname_valid = validate_nickname(new_text)
	update_nickname_feedback_validation_return(is_nickname_valid)
	update_register_btn(is_nickname_valid)

func _on_country_input_text_changed(new_text: String) -> void:
	var is_country_valid = validate_country(new_text)
	update_country_feedback_validation_return(is_country_valid)
	update_register_btn(is_country_valid)

func update_counter(new_text : String) -> void :
	char_count.text = "%d/12" % len(new_text)

func validate_country(country_name : String) -> bool:
	if len(country_name) <= 3 or country_name == " " or country_name.is_empty():
		return false
	else :
		return true

func validate_nickname(new_text : String) -> bool :
	if len(new_text) <= 2 or new_text.count(" ") >= 1 or new_text.is_empty():
		return false
	else :
		return true

func update_nickname_feedback_validation_return(is_valid : bool) -> void :
	if is_valid :
		nickname_feedback.text = ""
	else :
		nickname_feedback.text = "The nickname must be longer than 2 characters and contain no spaces."
		nickname_feedback.add_theme_color_override("font_color", "#d4293d")

func update_country_feedback_validation_return(is_valid : bool) -> void :
	if is_valid :
		country_feedback.text = ""
	else :
		country_feedback.text = "The country name must be longer than 3 characters"
		country_feedback.add_theme_color_override("font_color", "#d4293d")
