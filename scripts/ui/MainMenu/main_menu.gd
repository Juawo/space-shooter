extends Control

signal menu_closed

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var showing: bool = true

func hideMainMenu():
	animation_player.play("hide_menu")
	showing = false
	await animation_player.animation_finished
	self.visible = false
	
func showMainMenu():
	animation_player.play_backwards("hide_menu")
	showing = true
	self.visible = true
	

func _on_animation_player_animation_finished(animationName: StringName) -> void :
	if animationName == "hide_menu" and not showing :
		menu_closed.emit()
