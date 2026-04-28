extends Node

signal loaded_data

var high_score : int = 0
var player_id : String = "" 
var player_nickname : String = ""
var score_id : String = ""

#Configuracoes
var volume : float = 100.0
var language : int = 0
var control_mode : int = 0 # 0 para tilt e 1 para touch
var senibility : float = 100

# No topo do script SaveManager
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
			"senibility" : senibility
		}
	}
	
	save_file.store_line(JSON.stringify(data))
	save_file.close()
	
func load_data () -> void:
	if not FileAccess.file_exists(file_path):
		print ("O arquivo de dados nao existe.")
		loaded_data.emit()
		save_data()
	var load_file = FileAccess.open(file_path, FileAccess.READ)
	if not load_file:
		print ("Nao foi possivel abrir o arquivo para escrita.")
		return
		
	var json_data = JSON.parse_string(load_file.get_as_text())
	load_file.close()
	
	if json_data:
		high_score = json_data.get("high_score", 0)
		player_id = json_data.get("player_id", "")
		player_nickname = json_data.get("player_nickname", "Bob")
		score_id = json_data.get("score_id", "")
		# Carregando configuracoes
		if json_data.has("settings"):
			var s = json_data["settings"]
			volume = s.get("volume", 100.0)
			language = s.get("language", 0)
			control_mode = s.get("control_mode", 0)
			
		# Sincroniza com o SessionState
		SessionState.high_score = high_score
	loaded_data.emit()
