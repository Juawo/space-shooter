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
@onready var country_input: OptionButton = $MarginContainer/Panel/MarginContainer/VBoxContainer/Country/CountryInput

@onready var register_again_label: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/register_again_label
var register_again : bool = false 
var is_country_valid : bool 

var is_nickname_valid : bool

var accepted_policy : bool = false
const COUNTRIES = {
	"Brasil 🇧🇷": "BR",
	"Estados Unidos 🇺🇸": "US",
	"Portugal 🇵🇹": "PT",
	"Angola 🇦🇴": "AO",
	"Moçambique 🇲🇿": "MZ",
	"Alemanha 🇩🇪": "DE",
	"Argentina 🇦🇷": "AR",
	"Austrália 🇦🇺": "AU",
	"Canadá 🇨🇦": "CA",
	"Chile 🇨🇱": "CL",
	"China 🇨🇳": "CN",
	"Colômbia 🇨🇴": "CO",
	"Coreia do Sul 🇰🇷": "KR",
	"Espanha 🇪🇸": "ES",
	"França 🇫🇷": "FR",
	"Índia 🇮🇳": "IN",
	"Itália 🇮🇹": "IT",
	"Japão 🇯🇵": "JP",
	"México 🇲🇽": "MX",
	"Reino Unido 🇬🇧": "GB",
	"Rússia 🇷🇺": "RU",
	"Uruguai 🇺🇾": "UY",
	"Outro": "OT"
}

func _ready() -> void:
	ApiManager.play_registered.connect(update_interface_by_response_code_return)
	for i in COUNTRIES :
		country_input.add_item(i)

func _on_button_pressed() -> void:
	SoundManager.play_click()
	if !accepted_policy :
		detail_return.text = "To register, you need to accept the privacy policy."
		return
	
	register_btn.disabled = true
	if !validate_nickname(nickname_input.text):
		return

	var player_data = {
		"Nickname" : nickname_input.text,
		"Country" : get_selected_country(),
		"Age" : 10
	}
	print(player_data)
	ApiManager.register_player(player_data)
	
	nickname_input.editable = false
	country_input.disabled = true
	
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
	country_input.disabled = false
	return

func show_register_again_label(display: bool) -> void :
	register_again = display
	if register_again :
		register_again_label.visible = true
		register_again_label.text = "You are not found in the database, please register again."
		register_again_label.add_theme_color_override("font_color", "#d4293d")

func update_register_btn(is_activated : bool) -> void :
	register_btn.disabled = !is_activated 

func _on_nickname_input_text_changed(new_text: String) -> void:
	update_counter(new_text)
	is_nickname_valid = validate_nickname(new_text)
	update_nickname_feedback_validation_return(is_nickname_valid)
	update_register_btn(is_nickname_valid and accepted_policy)

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

func get_selected_country() -> String :
	var selected_index = country_input.selected
	var selected_text = country_input.get_item_text(selected_index)
	
	return COUNTRIES.get(selected_text, "OT") # "OT" como fallback (Outro)

func _on_country_label_2_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))


func _on_check_box_toggled(toggled_on: bool) -> void:
	accepted_policy = toggled_on
	update_register_btn(is_nickname_valid and accepted_policy)
