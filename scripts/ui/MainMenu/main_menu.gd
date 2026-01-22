extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var showing: bool = true

func hideMainMenu():
	animation_player.play("hide_menu")
	showing = false
	
func showMainMenu():
	animation_player.play_backwards("hide_menu")
	showing = true
