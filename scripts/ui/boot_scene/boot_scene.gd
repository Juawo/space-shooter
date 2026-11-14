extends Control

var update_pop_up : PackedScene = preload("res://scenes/ui/boot_scene/update_pop_up.tscn")
var register_scene : PackedScene = preload("res://scenes/ui/Register/register.tscn")
@onready var info: RichTextLabel = $MarginContainer/Control/VBoxContainer/info_wrapper/info
var player_check_return

func _ready() -> void:
	check_player_registration()
	SoundManager.set_music_opaque(true)

func check_player_registration():
	info.text = "[center][wave amp=40.0 freq=6.0 color=#FFFFFF][pulse color=#FFFFFF angle=0.0 height=1.05 freq=3.0]checking player registration...[/pulse][/wave][/center]"
	await ApiManager.register_session_player(SaveManager.playerIdentifier)
	go_to_main_menu()

func go_to_main_menu() -> void :
	get_tree().change_scene_to_file("res://scenes/game/main.tscn")
	SoundManager.set_music_opaque(false)
