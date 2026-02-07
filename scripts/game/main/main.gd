extends Node2D

# Aqui ficam os "componentes" do jogo e como sao orquestrados

# TODO : Lembrar de conectar os sinais dos componentes!

# "Componentes" do jogo
@onready var main_menu : Control = $UI/MainMenu
@onready var pause_menu: Control = $UI/PauseMenu

# Enum com os estados possiveis do jogo
enum GameStates { GAME, MAIN_MENU, PAUSED, GAME_OVER }
# Estado do jogo atual, por padrao/inicial em Menu
var state : GameStates = GameStates.MAIN_MENU : set = _set_state

func _ready() -> void:
	main_menu.connect("menu_closed",  _on_main_menu_closed)
	GameEvents.pause_requested.connect(_on_pause_requested)
	GameEvents.resume_requested.connect(_on_resume_requested)
	GameEvents.main_menu_requested.connect(_on_main_menu_requested)
	

func _on_main_menu_requested():
	state = GameStates.MAIN_MENU

func _on_main_menu_closed():
	state = GameStates.GAME

func _on_pause_requested():
	state = GameStates.PAUSED
	
func _on_resume_requested():
	state = GameStates.GAME
	
func _set_state(newValue : GameStates):
	state = newValue
	match newValue  :
		GameStates.MAIN_MENU :
			if pause_menu.is_showing:
				pause_menu.hide_pause_menu()
			print("Game state changed to Main Menu")
			main_menu.showMainMenu()
			
		GameStates.GAME :
			get_tree().paused = false
			if main_menu.showing:
				main_menu.hideMainMenu()
			if pause_menu.is_showing :
				pause_menu.hide_pause_menu()
			print("Game state changed to Game")
			
		GameStates.PAUSED :
			get_tree().paused = true
			pause_menu.show_pause_menu()
			print("Game state changed to Paused")
			
		GameStates.GAME_OVER :
			print("Game state changed to Game Over")
