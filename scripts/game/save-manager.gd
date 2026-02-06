extends Node

var high_score : int = 0
var player_id : String = "" 
var player_nickname : String = ""
var score_id : String = ""


# No topo do script SaveManager
var file_path : String

func _ready() -> void:
	# OS.SYSTEM_DIR_DOWNLOADS pega a pasta correta no Ubuntu ou Android
	var download_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	file_path = download_dir + "/space-shooter-save.json"
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
		"score_id": score_id
	}
	var json_data = JSON.stringify(data)
	save_file.store_line(json_data)
	save_file.close()
	
func load_data () -> void:
	if not FileAccess.file_exists(file_path):
		print ("O arquivo de dados nao existe.")
		save_data()
	var load_file = FileAccess.open(file_path, FileAccess.READ)
	if not load_file:
		print ("Nao foi possivel abrir o arquivo para escrita.")
		return
		
	var json_data = JSON.parse_string(load_file.get_as_text())
	load_file.close()
	
	if json_data:
		high_score = json_data.high_score
		player_id = json_data.player_id
		player_nickname = json_data.player_nickname
		score_id = json_data.score_id
		# Sincroniza com o SessionState
		SessionState.high_score = high_score
		
