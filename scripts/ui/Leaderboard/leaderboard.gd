extends Control

@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer
var row_scene := preload("res://scenes/ui/Leaderboard/leaderboard_row.tscn")

func _ready() -> void:
	ApiManager.highscores_received.connect(populate_leaderboard)
	ApiManager.get_leaderboard()

func populate_leaderboard(data : Array):
	if  data is not Array:
		printerr("Leaderboard recebida nao e um array!")
		return
	for i in range(len(data)):
		var new_scene = row_scene.instantiate()
		v_box_container.add_child(new_scene)
		new_scene.populate(data[i], i+1)
