extends Control

var server_game_version_data : Dictionary
var local_game_version : String
var update_pop_up : PackedScene = preload("res://scenes/ui/boot_scene/update_pop_up.tscn")
var register_scene : PackedScene = preload("res://scenes/ui/Register/register.tscn")
@onready var info: RichTextLabel = $MarginContainer/Control/VBoxContainer/info_wrapper/info
var player_check_return

func _ready() -> void:
	local_game_version = SaveManager.game_version
	ApiManager.latest_version_received.connect(_on_latestes_version_received)
	ApiManager.player_fetched.connect(_on_player_fetched)
	await ApiManager.latest_version_received
	compare_versions()
	SoundManager.set_music_opaque(true)

func compare_versions() -> void :
	info.text = "[center][wave amp=40.0 freq=6.0 color=#FFFFFF][pulse color=#FFFFFF angle=0.0 height=1.05 freq=3.0]comparing versions...[/pulse][/wave][/center]"
	if server_game_version_data.is_empty():
		print("server game version : ", server_game_version_data)
		check_player_registration()
		return
	if server_game_version_data.has("currentVersion"):
		if server_game_version_data["currentVersion"] != local_game_version:
			var update_pop_up_instance = update_pop_up.instantiate()
			add_child(update_pop_up_instance)
			update_pop_up_instance.populate_pop_up(server_game_version_data, local_game_version)
			update_pop_up_instance.pop_up_closed.connect(check_player_registration)
		else:
			check_player_registration()
	else:
		check_player_registration()

func _on_latestes_version_received(data : Dictionary, status_code : int) -> void :
	server_game_version_data = data

# TODO : Checar se o player existe no servidor tambem!

func check_player_registration():
	info.text = "[center][wave amp=40.0 freq=6.0 color=#FFFFFF][pulse color=#FFFFFF angle=0.0 height=1.05 freq=3.0]checking player registration...[/pulse][/wave][/center]"
	
	if SaveManager.player_id == "" or SaveManager.player_id == null:
		if server_game_version_data.is_empty(): # is offline
			print("Jogador sem registro E offline. Pulando registro para jogar localmente.")
			go_to_main_menu()
			return
		var scene = register_scene.instantiate()
		add_child(scene)
		await scene.register_pop_up_closed
		sync_high_score()
		return
	
	if not server_game_version_data.is_empty():
		print("Jogador possui ID local. Validando existência no servidor...")
		ApiManager.get_player()
		await ApiManager.player_fetched
		
		if player_check_return == 404:
			print("ID antigo inválido (404 no servidor). Resetando ID e abrindo Registro.")
			SaveManager.player_id = ""
			SaveManager.score_id = ""
			SaveManager.save_data() 
			var scene = register_scene.instantiate()
			add_child(scene)
			scene.show_register_again_label(true)
			await scene.register_pop_up_closed
			
			sync_high_score()
			return
	sync_high_score()

func _on_player_fetched(status_code) -> void :
	player_check_return = status_code
func sync_high_score() -> void :
	info.text = "[center][wave amp=40.0 freq=6.0 color=#FFFFFF][pulse color=#FFFFFF angle=0.0 height=1.05 freq=3.0]sync high score...[/pulse][/wave][/center]"
	ApiManager.sync_high_score()
	await ApiManager.highscore_sync_completed
	go_to_main_menu()

func go_to_main_menu() -> void :
	get_tree().change_scene_to_file("res://scenes/game/main.tscn")
	SoundManager.set_music_opaque(false)
