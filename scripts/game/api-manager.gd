extends Node

var http_request : HTTPRequest
var API_URL_BASE := "https://madalyn-thoroughgoing-continuedly.ngrok-free.dev"
var headers_base = ["Content-Type: application/json"]

var nickname : String 
var player_create_dto : Dictionary = {
	"nickname" : "bob",
	"country" : "Brasil",
	"age" : 10
}

func _ready() -> void:
	http_request = HTTPRequest.new()
	http_request.request_completed.connect(self._on_request_completed)
	add_child(http_request)
	
	#if SaveManager.player_id == "":
		#var test_data = {"nickname": "Bob", "country": "Brasil", "age": 20}
		#register_player(test_data)
	
func register_player(data : Dictionary):
	var url = API_URL_BASE+"/api/Player"
	var data_string = JSON.stringify(data)
	
	var err = http_request.request(url, headers_base, HTTPClient.METHOD_POST, data_string)
	if err != OK:
		printerr("Erro ao iniciar a requisição HTTP")

func _on_request_completed(result, response_code, headers, body):
	if response_code < 200 or response_code >= 300:
		printerr("Erro na requisicao! Codigo: %d" % response_code)
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if json:
		# Salvando o ID retornado pela sua API (PlayerDto)
		SaveManager.player_id = json.get("playerId", "")
		SaveManager.player_nickname = json.get("nickname", "")
		SaveManager.save_data()
		print("Jogador registrado e ID salvo: ", SaveManager.player_id)

func register_high_score(score : int) :
	pass

func get_all_highscores():
	pass
