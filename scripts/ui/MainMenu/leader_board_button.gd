extends Button

@export var pathScene : String = ""

func _on_pressed() -> void:
	SoundManager.play_click()
	#Add transition here
	get_tree().change_scene_to_file(pathScene)
