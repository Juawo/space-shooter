extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var showing: bool = false
@onready var background_tap_area: Button = $BackgroundTapArea

func hideMainMenu():
	background_tap_area.disabled = true
	animation_player.play("hide_menu")
	showing = false
	await animation_player.animation_finished
	self.visible = false
	
func showMainMenu():
	self.visible = true
	animation_player.play_backwards("hide_menu")
	await animation_player.animation_finished
	animation_player.play("idle")
	showing = true
	background_tap_area.disabled = false

func _on_background_tap_area_pressed() -> void:
	if is_visible_in_tree():
		GameEvents.game_requested.emit()
