extends Control

# PRELOADS (Removido o update_pop_up que não será mais usado)
var register_scene : PackedScene = preload("res://scenes/ui/Register/register.tscn")
@onready var info: RichTextLabel = $MarginContainer/Control/VBoxContainer/info_wrapper/info

var player_check_return
var is_server_online := false

func _ready() -> void:
	# Conectamos apenas os sinais necessários para o fluxo do jogador
	ApiManager.player_fetched.connect(_on_player_fetched)
	SoundManager.set_music_opaque(true)
	
	# Iniciamos o fluxo direto de checagem do jogador
	start_boot_flow()

func start_boot_flow() -> void:
	info.text = "[center][wave amp=40.0 freq=6.0 color=#FFFFFF][pulse color=#FFFFFF angle=0.0 height=1.05 freq=3.0]connecting to server...[/pulse][/wave][/center]"
	
	# Fazemos uma requisição rápida para saber se o servidor está online.
	# Dica: Você pode usar a própria função de obter jogador ou criar um ping na sua API.
	# Se a requisição falhar ou der timeout, assumimos que está offline.
	if SaveManager.player_id != "" and SaveManager.player_id != null:
		ApiManager.get_player()
		
		# Criamos um timer de segurança (timeout) de 5 segundos.
		# Se o Render estiver dormindo ou o celular sem net, o jogo não fica travado infinito!
		var timeout_timer = get_tree().create_timer(5.0)
		
		# Esperamos o sinal do servidor OU o timer de timeout acabar (o que acontecer primeiro)
		await get_tree().process_frame # pequeno delay para a requisição de get_player iniciar
		while not ApiManager.player_fetched.is_connected(_on_player_fetched) and timeout_timer.time_left > 0.0:
			if player_check_return != null:
				break
			await get_tree().create_timer(0.1).timeout
		
		if player_check_return != null:
			is_server_online = true
		else:
			is_server_online = false
			print("Timeout ao conectar ao servidor. Rodando em modo offline.")
	else:
		# Se o jogador não tem ID, vamos tentar abrir a tela de registro.
		# Faremos uma verificação rápida de ping na API se achar necessário,
		# ou simplesmente tentamos abrir o registro.
		is_server_online = true # Assumimos online inicialmente para tentar o registro
	
	check_player_registration()

func check_player_registration() -> void:
	info.text = "[center][wave amp=40.0 freq=6.0 color=#FFFFFF][pulse color=#FFFFFF angle=0.0 height=1.05 freq=3.0]checking player registration...[/pulse][/wave][/center]"
	
	# CASO 1: Jogador não tem registro local (Primeira vez jogando)
	if SaveManager.player_id == "" or SaveManager.player_id == null:
		if not is_server_online:
			print("Jogador sem registro E offline. Pulando registro para jogar localmente.")
			go_to_main_menu()
			return
		
		# Abre a tela de registro
		var scene = register_scene.instantiate()
		add_child(scene)
		await scene.register_pop_up_closed
		sync_high_score()
		return
	
	# CASO 2: Jogador tem registro local, vamos validar com o servidor online
	if is_server_online:
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
		
		# Se o ID for válido, sincroniza os pontos
		sync_high_score()
	else:
		# Se estiver offline mas já tiver ID local, vai direto pro jogo jogar localmente
		print("Jogador registrado mas offline. Iniciando jogo local.")
		go_to_main_menu()

func _on_player_fetched(status_code) -> void :
	player_check_return = status_code

func sync_high_score() -> void :
	if is_server_online:
		info.text = "[center][wave amp=40.0 freq=6.0 color=#FFFFFF][pulse color=#FFFFFF angle=0.0 height=1.05 freq=3.0]sync high score...[/pulse][/wave][/center]"
		ApiManager.sync_high_score()
		await ApiManager.highscore_sync_completed
	go_to_main_menu()

func go_to_main_menu() -> void :
	get_tree().change_scene_to_file("res://scenes/game/main.tscn")
	SoundManager.set_music_opaque(false)
