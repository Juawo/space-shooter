extends Control

@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer
var row_scene := preload("res://scenes/ui/Leaderboard/leaderboard_row.tscn")

func _ready() -> void:
	ApiManager.highscores_received.connect(populate_leaderboard)

func populate_leaderboard(data : Dictionary):
	for player in data:
		var new_scene = row_scene.instantiate()
		
		v_box_container.add_child(new_scene)
		
