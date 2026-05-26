extends Control

var server_game_version_data : Dictionary
var local_game_version : String
var update_pop_up : PackedScene = preload("res://scenes/ui/boot_scene/update_pop_up.tscn")

# TODO : The register scene come to here, and the unregistered player logic
# TODO : Compare local player's HighScore VS server player's HighScore to fetch

func _ready() -> void:
	local_game_version = SaveManager.game_version
	ApiManager.latest_version_received.connect(_on_latestes_version_received)
	await ApiManager.latest_version_received
	compare_versions()

func compare_versions() -> void :
	if server_game_version_data.has("currentVersion"):
		if server_game_version_data["currentVersion"] != local_game_version:
			print("DIFF!!! Mostrar Pop-up de Update")
			var pop_up = update_pop_up.instantiate()
			add_child(pop_up)
			pop_up.populate_pop_up(server_game_version_data, local_game_version)
		else:
			print("Versao atualizada! Seguir para o Menu")
			go_to_main_menu()
	else:
		printerr("Erro: Chave 'currentVersion' nao encontrada no JSON da API")
		go_to_main_menu()
	
func _on_latestes_version_received(data : Dictionary) -> void :
	server_game_version_data = data
	print("Chegou verssao da API")

func go_to_main_menu() -> void :
	get_tree().change_scene_to_file("res://scenes/game/main.tscn")
