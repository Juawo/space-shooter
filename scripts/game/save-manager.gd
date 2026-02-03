extends Node

var file_path :String = "user://space-shooter.json"
var high_score :int = 0

func _ready() -> void:
	load_data()
	SessionState.high_score = high_score
	
func save_data () -> void:
	var save_file = FileAccess.open(file_path, FileAccess.WRITE)
	if not save_file:
		print ("Nao foi possivel abrir o arquivo para escrita.")
		return
		
	var jsaon_data = JSON.stringify(high_score)
	save_file.store_line(jsaon_data)
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
	
	high_score = json_data
	print (high_score)
		
