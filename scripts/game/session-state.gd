extends Node

signal value_changed(value:int)
signal high_score_changed(value:int)

var current_score :int = 0 :
	set (new_value) :
		current_score = new_value
		value_changed.emit(new_value)
		if new_value > high_score:
			high_score = new_value

var high_score :int = 0 :
	set (new_value) :
		high_score = new_value
		high_score_changed.emit(new_value)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameEvents.game_over.connect(_on_gameplay_end)
	GameEvents.main_menu_requested.connect(_on_gameplay_end)

func _on_gameplay_end():
	if SaveManager.high_score < high_score :
		SaveManager.high_score = high_score
		SaveManager.save_data()
		ApiManager.register_high_score(high_score)
