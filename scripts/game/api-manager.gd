extends Node

signal highscores_received(data)
signal play_registered(data:bool)

var API_URL_BASE := "https://madalyn-thoroughgoing-continuedly.ngrok-free.dev/"
var headers_base = ["Content-Type: application/json"]

func register_player(data : Dictionary):
	var request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_register_request_completed)
	
	var url = API_URL_BASE+"/api/Player"
	var data_string = JSON.stringify(data)
	
	var err = request.request(url, headers_base, HTTPClient.METHOD_POST, data_string)
	if err != OK:
		printerr("Erro ao iniciar a requisição HTTP")

func _on_register_request_completed(result, response_code, headers, body):
	if response_code < 200 or response_code >= 300:
		printerr("Erro na requisicao! Codigo: %d" % response_code)
		play_registered.emit(false)
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if json:
		# Salvando o ID retornado pela  API (PlayerDto)
		SaveManager.player_id = json.playerId
		SaveManager.player_nickname = json.nickname
		SaveManager.save_data()
		play_registered.emit(true)
		print("Jogador registrado e ID salvo: ", SaveManager.player_id)

func register_high_score(score : int) :
	# Criando req HTTP
	var request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_score_create_update_completed.bind(request))
	
	var url = API_URL_BASE+"/api/HighScore/%s" % [SaveManager.player_id]
	var data_string = JSON.stringify({"Value": score})

	var method = HTTPClient.METHOD_POST
	if SaveManager.score_id != "":
		method = HTTPClient.METHOD_PUT
		url += "/%s" % [SaveManager.score_id]
	
	request.request(url, headers_base, method, data_string)

func _on_score_create_update_completed(result, response_code, headers, body, request_node):
	# POST retorna 201, PUT retorna 204
	if response_code == 201: 
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json and json.has("highScoreId"): 
			SaveManager.score_id = json.highScoreId
			SaveManager.save_data()
			print("Novo HighScore criado!")
			
	elif response_code == 204:
		print("HighScore atualizado com sucesso (PUT)!")
	request_node.queue_free()

func get_leaderboard():
	var request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_all_score_sync.bind(request))
	
	print("ID : " + SaveManager.player_id)
	
	var url = API_URL_BASE+"api/HighScore/leaderboard/%s" % [SaveManager.player_id]
	print(url)
	
	var err = request.request(url, headers_base, HTTPClient.METHOD_GET)
	if err != OK:
		printerr("GET HIGHSCORE - Erro ao iniciar a requisicao HTTP")

func _on_all_score_sync(result, response_code, headers, body, request_node):
	print("Status code : " + str(response_code))
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		highscores_received.emit(json)
		print(json)
		
	request_node.queue_free()
	
	
