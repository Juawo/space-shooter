extends Node

signal highscores_received(data, status_code)
signal play_registered(data:bool, code)
signal nickname_updated(response_code)
signal highscore_sync_completed
signal player_fetched(status_code)

var API_URL_BASE := "https://madalyn-thoroughgoing-continuedly.ngrok-free.dev/"
var headers_base = ["Content-Type: application/json"]
var register_scene := preload("res://scenes/ui/Register/register.tscn")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_configs()

func _load_configs():
	var config = ConfigFile.new()
	var err = config.load("res://configs/secret_configs.cfg")
	if err == OK:
		API_URL_BASE = config.get_value("network", "api_url", API_URL_BASE)
		print("Load network configurations sucessfuly")
		print(API_URL_BASE)
	else :
		print("Network configuration file not found. Using development configuration.")

func sync_high_score() -> void :
	var request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_sync_high_score_completed.bind(request))
	# Player not registered or don't have any high score in the server
	if SaveManager.player_id.is_empty():
		await get_tree().process_frame
		highscore_sync_completed.emit()
		return
	if SaveManager.score_id.is_empty():
		if SaveManager.high_score > 0 :
			register_high_score(SaveManager.high_score)
		else :
			await get_tree().process_frame
			highscore_sync_completed.emit()
		return
	
	var url = API_URL_BASE + "api/HighScore/%s/%s" % [SaveManager.player_id, SaveManager.score_id]
	var err = request.request(url, headers_base, HTTPClient.METHOD_GET)
	if err != OK:
		printerr("GET Sync High Score - Erro ao iniciar a requisicao HTTP")
		highscore_sync_completed.emit()
@warning_ignore("unused_parameter")
func _on_sync_high_score_completed(result, response_code, headers, body, request_node) :
	print("Status code LV : " + str(response_code))
	
	if response_code != 200:
		print("Falha na sincronização de HighScore (Offline). Seguindo com dados locais.")
		highscore_sync_completed.emit()
		request_node.queue_free()
		return
		
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json.has("value") :
		if SaveManager.high_score > json["value"] :
			register_high_score(SaveManager.high_score)
			request_node.queue_free()
			return
		if SaveManager.high_score < json["value"]:
			SaveManager.high_score = json["value"]
			SaveManager.save_data()
	
	highscore_sync_completed.emit()
	request_node.queue_free()

func register_player(data : Dictionary):
	var request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_register_request_completed.bind(request))
	
	var url = API_URL_BASE+"api/Player"
	var data_string = JSON.stringify(data)
	
	var err = request.request(url, headers_base, HTTPClient.METHOD_POST, data_string)
	if err != OK:
		printerr("Erro ao iniciar a requisição HTTP")
		play_registered.emit(false, null)
@warning_ignore("unused_parameter")
func _on_register_request_completed(result, response_code, headers, body, request_node):
	if response_code < 200 or response_code >= 300:
		printerr("Erro na requisicao! Codigo: %d" % response_code)
		play_registered.emit(false, response_code)
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if json:
		# Salvando o ID retornado pela  API (PlayerDto)
		SaveManager.player_id = json.playerId
		SaveManager.player_nickname = json.nickname
		SaveManager.save_data()
		play_registered.emit(true,response_code)
		print("Jogador registrado e ID salvo: ", SaveManager.player_id)
	request_node.queue_free()

func register_high_score(score : int) :
	# Criando req HTTP
	var request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_score_create_update_completed.bind(request))
	
	var url = API_URL_BASE+"api/HighScore/%s" % [SaveManager.player_id]
	var data_string = JSON.stringify({"Value": score})

	var method = HTTPClient.METHOD_POST
	if SaveManager.score_id != "":
		method = HTTPClient.METHOD_PATCH
		url += "/%s" % [SaveManager.score_id]
	
	request.request(url, headers_base, method, data_string)
@warning_ignore("unused_parameter")
func _on_score_create_update_completed(result, response_code, headers, body, request_node):
	# POST retorna 201, PUT retorna 204
	if response_code == 201: 
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json and json.has("highScoreId"): 
			SaveManager.score_id = json.highScoreId
			SaveManager.save_data()
			
	elif response_code == 204:
		print("HighScore atualizado com sucesso (PUT)!")
	highscore_sync_completed.emit()
	request_node.queue_free()

func get_leaderboard():
	var request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_all_score_sync.bind(request))
	
	var url = API_URL_BASE+"api/HighScore/leaderboard/%s" % [SaveManager.player_id]
	
	var err = request.request(url, headers_base, HTTPClient.METHOD_GET)
	if err != OK:
		printerr("GET HIGHSCORE - Erro ao iniciar a requisicao HTTP")
		highscores_received.emit(null, null)
@warning_ignore("unused_parameter")
func _on_all_score_sync(result, response_code, headers, body, request_node):
	print("Status code  aaa: " + str(response_code))
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		highscores_received.emit(json, response_code)
	else :
		highscores_received.emit(null, response_code)
	request_node.queue_free()

func get_player():
	var request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_get_player.bind(request))
	
	if SaveManager.player_id.is_empty() :
		player_fetched.emit(null)
		return
	
	var url = API_URL_BASE+"api/Player/%s" % [SaveManager.player_id]
	
	var err = request.request(url, headers_base, HTTPClient.METHOD_GET)
	if err != OK:
		printerr("GET HIGHSCORE - Erro ao iniciar a requisicao HTTP")
		player_fetched.emit(null)
@warning_ignore("unused_parameter")
func _on_get_player(result, response_code, headers, body, request_node):
	if response_code == 200:
		player_fetched.emit(response_code)
	else :
		player_fetched.emit(response_code)
	request_node.queue_free()

func update_nickname(new_nickname : String) -> void:
	var request_nickname = HTTPRequest.new()
	add_child(request_nickname)
	request_nickname.request_completed.connect(_on_update_nickname_completed.bind(request_nickname))
	
	var url = API_URL_BASE+"api/player/%s" % [SaveManager.player_id]
	var data_string = JSON.stringify({"Nickname" : new_nickname})
	
	request_nickname.request(url,headers_base,HTTPClient.METHOD_PATCH,data_string)
@warning_ignore("unused_parameter")
func _on_update_nickname_completed(result, response_code, headers, body, request_node) :
	nickname_updated.emit(response_code)
	request_node.queue_free()
