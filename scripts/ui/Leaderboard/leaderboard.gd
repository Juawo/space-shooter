extends Control

@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer
var row_scene := load("res://scenes/ui/Leaderboard/leaderboard_row.tscn")
var main_scene := load("res://scenes/game/main.tscn")
@onready var erro_return: RichTextLabel = $MarginContainer/VBoxContainer/Panel/MarginContainer/erro_return

func _ready() -> void:
	ApiManager.highscores_received.connect(populate_leaderboard)
	ApiManager.get_leaderboard()

func populate_leaderboard(data, status_code):
	if status_code != 200:
		if status_code == null or status_code == 0:
			erro_return.text = "[center][wave amp=40.0 freq=6.0 color=#FFFFFF][pulse color=#FFFFFF angle=0.0 height=1.05 freq=3.0]You are offline, the game can't fetch the data.[/pulse][/wave][/center]"
			return
		else:
			erro_return.text = "[center][wave amp=40.0 freq=6.0 color=#FFFFFF][pulse color=#FFFFFF angle=0.0 height=1.05 freq=3.0]Error when trying to fetch the leaderboard - Status Code : %d[/pulse][/wave][/center]" % status_code
			return
	if data == null or typeof(data) != TYPE_ARRAY:
		erro_return.text = "[center][wave amp=40.0 freq=6.0 color=#FFFFFF][pulse color=#FFFFFF angle=0.0 height=1.05 freq=3.0]Error in data coming from the server.[/pulse][/wave][/center]"
		return
	erro_return.visible = false
	
	for i in range(len(data)):
		var new_scene = row_scene.instantiate()
		v_box_container.add_child(new_scene)
		new_scene.populate(data[i], i+1)
		if i % 2 == 0:
			new_scene.get_node("Panel").self_modulate = Color(1, 1, 1, 0.05)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_scene)
