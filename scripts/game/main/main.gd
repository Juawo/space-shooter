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

func _on_main_menu_closed():
	state = GameStates.GAME

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
			print("Game state changed to Paused")
		GameStates.GAME_OVER :
			print("Game state changed to Game Over")


# Apenas para testar troca de estado
#var states = [GameStates.MAIN_MENU, GameStates.PAUSED, GameStates.GAME,GameStates.GAME_OVER]
#var i = 0
#
#func _input(event: InputEvent) -> void:
	#if(event is InputEventKey):
		#if(i > len(states) - 1):
			#print(i)
			#i = 0
		#state = states[i]
		#i += 1
