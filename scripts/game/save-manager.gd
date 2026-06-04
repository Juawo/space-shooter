extends Node

signal loaded_data

# Player
var high_score : int = 0
var player_id : String = "" 
var player_nickname : String = ""
var score_id : String = ""

#Configuracoes
var volume : float = 100.0
var language : int = 0
var control_mode : int = -1 # 0 para tilt e 1 para touch
var sensibility : float = 100
var has_chosen_control : bool = false
#GameVersion
const CURRENT_CODE_VERSION : String = "1.0.1"
var game_version : String = CURRENT_CODE_VERSION

var file_path : String

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# OS.SYSTEM_DIR_DOWNLOADS pega a pasta correta no Ubuntu ou Android
	file_path = "user://space-shooter-save.json"
	load_data()
	
func save_data () -> void:
	var save_file = FileAccess.open(file_path, FileAccess.WRITE)
	if not save_file:
		print ("Nao foi possivel abrir o arquivo para escrita.")
		return
	
	var data = {
		"high_score": high_score,
		"player_id": player_id,
		"player_nickname": player_nickname,
		"score_id": score_id,
		"settings" : {
			"volume" : volume,
			"language" : language,
			"control_mode" : control_mode,
			"sensibility" : sensibility,
			"has_chosen_control" : has_chosen_control
		},
		"game_version" : game_version
	}
	
	save_file.store_line(JSON.stringify(data))
	save_file.close()

func load_data () -> void:
	if not FileAccess.file_exists(file_path):
		print ("O arquivo de dados nao existe.")
		# Se não existe, usamos a versão atual do código
		game_version = CURRENT_CODE_VERSION
		loaded_data.emit()
		save_data()
		return # Adicione o return aqui para evitar ler um arquivo inexistente abaixo
		
	var load_file = FileAccess.open(file_path, FileAccess.READ)
	if not load_file:
		print ("Nao foi possivel abrir o arquivo para leitura.")
		return
		
	var json_data = JSON.parse_string(load_file.get_as_text())
	load_file.close()
	
	if json_data:
		high_score = json_data.get("high_score", 0)
		player_id = json_data.get("player_id", "")
		player_nickname = json_data.get("player_nickname", "Bob")
		score_id = json_data.get("score_id", "")
		
		# o que está guardado no arquivo
		var saved_version = json_data.get("game_version", "1.0.0")
		# sincronização de versão
		if saved_version != CURRENT_CODE_VERSION:
			print("Upgrade detectado! Arquivo antigo: ", saved_version, " | Código Atual: ", CURRENT_CODE_VERSION)
			# Forçamos a variável local a usar a versão atualizada do código
			game_version = CURRENT_CODE_VERSION
			# Chamamos o save para atualizar o arquivo .json em disco imediatamente!
			save_data()
		else:
			game_version = saved_version

		# Carregando configuracoes
		if json_data.has("settings"):
			var s = json_data["settings"]
			volume = s.get("volume", 100.0)
			language = s.get("language", 0)
			control_mode = s.get("control_mode", -1)
			sensibility = s.get("sensibility", 100)
			has_chosen_control = s.get("has_chosen_control", false)
			
	SessionState.high_score = high_score
	loaded_data.emit()

func update_nickname(new_nickname : String) -> void :
	player_nickname = new_nickname
	save_data()
