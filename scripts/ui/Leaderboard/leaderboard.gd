extends Control

@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer
var row_scene := load("res://scenes/ui/Leaderboard/leaderboard_row.tscn")
var main_scene := load("res://scenes/game/main.tscn")

func _ready() -> void:
	ApiManager.highscores_received.connect(populate_leaderboard)
	ApiManager.get_leaderboard()

func populate_leaderboard(data : Array):
	print("Opa")
	if  data is not Array:
		printerr("Leaderboard recebida nao e um array!")
		return
	for i in range(len(data)):
		var new_scene = row_scene.instantiate()
		v_box_container.add_child(new_scene)
		new_scene.populate(data[i], i+1)
		if i % 2 == 0:
			new_scene.get_node("Panel").self_modulate = Color(1, 1, 1, 0.05) # Sombra leve


func _on_back_button_pressed() -> void:
	print("clicado")
	get_tree().change_scene_to_packed(main_scene)
