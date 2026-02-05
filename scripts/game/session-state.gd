extends Node

var current_score :int = 0 :
	set (new_value) :
		current_score = new_value
		print(current_score)
		if new_value > high_score:
			high_score = new_value
			SaveManager.high_score = high_score
			SaveManager.save_data()
			
var high_score :int = 0
