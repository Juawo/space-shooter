extends Control

var server_game_version_data : Dictionary
var local_game_version : String
var update_pop_up : PackedScene = preload("res://scenes/ui/boot_scene/update_pop_up.tscn")
var register_scene : PackedScene = preload("res://scenes/ui/Register/register.tscn")
@onready var info: RichTextLabel = $MarginContainer/Control/VBoxContainer/info_wrapper/info

# TODO : Compare local player's HighScore VS server player's HighScore to fetch

func _ready() -> void:
	local_game_version = SaveManager.game_version
	ApiManager.latest_version_received.connect(_on_latestes_version_received)
	await ApiManager.latest_version_received
	compare_versions()
	

func compare_versions() -> void :
	info.text = "[center][wave amp=40.0 freq=6.0 color=#FFFFFF][pulse color=#FFFFFF angle=0.0 height=1.05 freq=3.0]comparing versions...[/pulse][/wave][/center]"
	if server_game_version_data.has("currentVersion"):
		if server_game_version_data["currentVersion"] != local_game_version:
			var update_pop_up_instance = update_pop_up.instantiate()
			add_child(update_pop_up_instance)
			update_pop_up_instance.populate_pop_up(server_game_version_data, local_game_version)
			update_pop_up_instance.pop_up_closed.connect(check_player_registration)
		else:
			print("Versao atualizada! Seguir para o Menu")
			
	else:
		printerr("Erro: Chave 'currentVersion' nao encontrada no JSON da API")

	
func _on_latestes_version_received(data : Dictionary) -> void :
	server_game_version_data = data
	print("Chegou verssao da API")

func check_player_registration():
	info.text = "[center][wave amp=40.0 freq=6.0 color=#FFFFFF][pulse color=#FFFFFF angle=0.0 height=1.05 freq=3.0]checking player registration...[/pulse][/wave][/center]"
	if SaveManager.player_id == "" or SaveManager.player_id == null:
		var scene = register_scene.instantiate()
		add_child(scene)
		await scene.register_pop_up_closed
	sync_high_score()

func sync_high_score() -> void :
	info.text = "[center][wave amp=40.0 freq=6.0 color=#FFFFFF][pulse color=#FFFFFF angle=0.0 height=1.05 freq=3.0]sync high score...[/pulse][/wave][/center]"
	ApiManager.sync_high_score()
	await ApiManager.highscore_sync_completed
	go_to_main_menu()

func go_to_main_menu() -> void :
	get_tree().change_scene_to_file("res://scenes/game/main.tscn")
