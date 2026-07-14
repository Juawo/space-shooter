extends Button

var pathScene : String = "res://scenes/ui/Settings/settings.tscn"

func _on_pressed() -> void:
	SoundManager.play_click()
	get_tree().change_scene_to_file(pathScene)
