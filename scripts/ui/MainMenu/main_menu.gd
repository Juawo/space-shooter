extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var showing: bool = false

func hideMainMenu():
	animation_player.play("hide_menu")
	showing = false
	await animation_player.animation_finished
	self.visible = false
	
func showMainMenu():
	animation_player.play_backwards("hide_menu")
	animation_player.play("idle")
	showing = true
	self.visible = true

func _on_background_tap_area_pressed() -> void:
	if is_visible_in_tree():
		GameEvents.game_requested.emit()
