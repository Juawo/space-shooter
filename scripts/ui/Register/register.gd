extends Control

signal register_pop_up_closed

@onready var v_box_container: VBoxContainer = $MarginContainer/Panel/MarginContainer/VBoxContainer

@onready var nickname_input: LineEdit = $MarginContainer/Panel/MarginContainer/VBoxContainer/Nickname/nickname_type/nickname_input
@onready var char_count: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/Nickname/nickname_type/char_count
@onready var nickname_feedback: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/Nickname/nicknameFeedback

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var feedback: Label = $MarginContainer/Panel/MarginContainer/Feedback

@onready var detail_return: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/detail_return

@onready var register_btn: Button = $MarginContainer/Panel/MarginContainer/VBoxContainer/register_btn

@onready var timer: Timer = $Timer

@onready var register_again_label: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/register_again_label
var register_again : bool = false 
var is_nickname_valid : bool

func _ready() -> void:
	ApiManager.nickname_updated.connect(update_interface_by_response_code_return)

func _on_button_pressed() -> void:
	SoundManager.play_click()
	register_btn.disabled = true
	
	if !validate_nickname(nickname_input.text):
		return
	
	ApiManager.update_nickname(nickname_input.text)
	
	nickname_input.editable = false
	
	detail_return.text = "Awaiting server response..."
	detail_return.add_theme_color_override("font_color", "#ffff")

func update_interface_by_response_code_return(response_code) -> void :
	
	match response_code:
		200 : 
			detail_return.text = "Player Registered!"
			detail_return.add_theme_color_override("font_color", "#00c805")
			timer.start(2)
			await timer.timeout
			animation_player.play("close_register")
			await animation_player.animation_finished
			register_pop_up_closed.emit()
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
			timer.start(2)
			await timer.timeout
			animation_player.play("close_register")
			await animation_player.animation_finished
			register_pop_up_closed.emit()
			queue_free()
		null :
			detail_return.text = "You are offline. Try again when you are online."
			detail_return.add_theme_color_override("font_color", "#d4293d")
			timer.start(2)
			await timer.timeout
			animation_player.play("close_register")
			await animation_player.animation_finished
			register_pop_up_closed.emit()
			queue_free()
		_:
			detail_return.text = "Type your info for register."
			detail_return.add_theme_color_override("font_color", "#ffffff")
	
	nickname_input.editable = true
	return

func show_register_again_label(display: bool) -> void :
	register_again = display
	if register_again :
		register_again_label.visible = true
		register_again_label.text = "You are not found in the database, try again later."
		register_again_label.add_theme_color_override("font_color", "#d4293d")

func update_register_btn(is_activated : bool) -> void :
	register_btn.disabled = !is_activated 

func _on_nickname_input_text_changed(new_text: String) -> void:
	update_counter(new_text)
	is_nickname_valid = validate_nickname(new_text)
	update_nickname_feedback_validation_return(is_nickname_valid)
	if is_nickname_valid :
		update_register_btn(is_nickname_valid)

func update_counter(new_text : String) -> void :
	char_count.text = "%d/12" % len(new_text)

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
