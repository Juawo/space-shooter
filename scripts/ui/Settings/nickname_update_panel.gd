extends Control

# TODO : Adicionar animacao de surgimento e saida

@onready var nickname_input: LineEdit = $MarginContainer/Panel/MarginContainer/VBoxContainer/MarginContainer/Nickname/nickname_type/nickname_input
@onready var char_count: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/MarginContainer/Nickname/nickname_type/char_count
@onready var detail_return: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/MarginContainer/Nickname/detail_return
@onready var register_btn: Button = $MarginContainer/Panel/MarginContainer/VBoxContainer/register_btn
@onready var background: ColorRect = $background
var new_nickname : String = ""
var is_nickname_updated : bool :
	set(new_value) :
		is_nickname_updated = new_value
		if !new_value :
			nickname_input.editable = true

func _ready() -> void:
	ApiManager.nickname_updated.connect(update_by_response_code_return)
	ApiManager.nickname_updated.connect(update_save_manager_nickname)
	background.gui_input.connect(_on_background_clicked)
	
# Quando digitar esse e chamado para alterar o contador
func update_counter(new_text : String) -> void :
	char_count.text = "%d/12" % len(new_text)

func update_register_btn(is_activated : bool) -> void :
	register_btn.disabled = !is_activated 
	
# Verifica em todo tempo, se for false ai atualiza o btn pra nao ativo
# TODO : Se tivesse como dar retorno se fosse igual ao atual
func validate_nickname(new_text : String) -> bool :
	if len(new_text) <= 2 or new_text.count(" ") >= 1 :
		return false
	else :
		return true

func update_by_response_code_return(response_code) -> void :
	match response_code:
		204 : 
			detail_return.text = "Player nickname changed!"
			detail_return.add_theme_color_override("font_color", "#00c805")
			is_nickname_updated = true
		404 : 
			detail_return.text = "Player not found, uninstall and make register again."
			detail_return.add_theme_color_override("font_color", "#d4293d")
			is_nickname_updated = false
		409 : 
			detail_return.text = "Another player has this nickname."
			detail_return.add_theme_color_override("font_color", "#d49a3d")
			is_nickname_updated = false
		400 :
			detail_return.text = "This nickname it's not valid."
			detail_return.add_theme_color_override("font_color", "#d4293d")
			is_nickname_updated = false
		500 :
			detail_return.text = "Error in the server."
			detail_return.add_theme_color_override("font_color", "#d4293d")
			is_nickname_updated = false
		_:
			detail_return.text = "Type your new nickname"
			detail_return.add_theme_color_override("font_color", "#ffffff")
			is_nickname_updated = false
	return

func update_detail_validation_return(is_valid : bool) -> void :
	if is_valid :
		detail_return.text = ""
	else :
		detail_return.text = "The nickname must be longer than 2 characters and contain no spaces."
		detail_return.add_theme_color_override("font_color", "#d4293d")

func update_save_manager_nickname(response_code) -> void :
	if response_code == 204 :
		SaveManager.update_nickname(new_nickname)

func _on_register_btn_pressed() -> void:
	nickname_input.editable = false
	new_nickname = nickname_input.text
	ApiManager.update_nickname(new_nickname)
	detail_return.text = "Awiating server response..."
	detail_return.add_theme_color_override("font_color", "#ffff")

func _on_nickname_input_text_changed(new_text: String) -> void:
	update_counter(new_text)
	var is_nickname_valid = validate_nickname(new_text)
	update_detail_validation_return(is_nickname_valid)
	update_register_btn(is_nickname_valid)

func _on_background_clicked(event : InputEvent) -> void :
	print("Opa")
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT \
	or event is InputEventScreenTouch:
		print("Background clicado")
		queue_free()
