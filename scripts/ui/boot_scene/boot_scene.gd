extends Control

var update_pop_up : PackedScene = preload("res://scenes/ui/boot_scene/update_pop_up.tscn")
var register_scene : PackedScene = preload("res://scenes/ui/Register/register.tscn")
@onready var info: RichTextLabel = $MarginContainer/Control/VBoxContainer/info_wrapper/info

var cloud_score : int

func _ready() -> void:
	ApiManager.got_player_rank.connect(_on_got_player_rank)
	SoundManager.set_music_opaque(true)
	await check_player_registration()
	await sync_player_highscore()
	go_to_main_menu()

func check_player_registration():
	info.text = "[center][wave amp=40.0 freq=6.0 color=#FFFFFF][pulse color=#FFFFFF angle=0.0 height=1.05 freq=3.0]checking player registration...[/pulse][/wave][/center]"
	await ApiManager.register_session_player(SaveManager.playerIdentifier)

func sync_player_highscore() -> void:
	info.text = "[center][wave amp=40.0 freq=6.0 color=#FFFFFF][pulse color=#FFFFFF angle=0.0 height=1.05 freq=3.0]synchronizing highscore...[/pulse][/wave][/center]"
	
	if SaveManager.high_score == null or SaveManager.high_score == 0:
		return
	
	ApiManager.get_player_rank()
	await ApiManager.got_player_rank
	
	if SaveManager.high_score > cloud_score :
		ApiManager.submit_score(SaveManager.high_score)
	else :
		SaveManager.update_high_score(cloud_score)

func _on_got_player_rank(_status_code, _rank, score) -> void:
	cloud_score = score

func go_to_main_menu() -> void :
	get_tree().change_scene_to_file("res://scenes/game/main.tscn")
	SoundManager.set_music_opaque(false)
