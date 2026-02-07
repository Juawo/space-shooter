extends Node2D

# Aqui ficam os "componentes" do jogo e como sao orquestrados

# TODO : Lembrar de conectar os sinais dos componentes!

# "Componentes" do jogo
@onready var main_menu : Control = $UI/MainMenu

# Enum com os estados possiveis do jogo
enum GameStates { GAME, MAIN_MENU, PAUSED, GAME_OVER }
# Estado do jogo atual, por padrao/inicial em Menu
var state : GameStates = GameStates.MAIN_MENU : set = _set_state

func _ready() -> void:
	main_menu.connect("menu_closed",  _on_main_menu_closed)
	GameEvents.pause_requested.connect(_on_pause_requested)

func _on_main_menu_closed():
	state = GameStates.GAME

func _on_pause_requested():
	state = GameStates.PAUSED

func _set_state(newValue : GameStates):
	state = newValue
	match newValue  :
		GameStates.MAIN_MENU :
			print("Game state changed to Main Menu")
			main_menu.showMainMenu()
		GameStates.GAME :
			main_menu.hideMainMenu()
			print("Game state changed to Game")
		GameStates.PAUSED :
			get_tree().paused = true
			print("Game state changed to Paused")
		GameStates.GAME_OVER :
			print("Game state changed to Game Over")
