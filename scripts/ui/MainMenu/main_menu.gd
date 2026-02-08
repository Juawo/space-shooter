extends Control

signal menu_closed

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

func _on_animation_player_animation_finished(animationName: StringName) -> void :
	if animationName == "hide_menu" and not showing :
		menu_closed.emit()

# TODO : Corrigir clique no background tap area
func _on_background_tap_area_pressed() -> void:
	if is_visible_in_tree():
		print("Clicado!")
		GameEvents.game_requested.emit()
	else:
		print("Clicado mas nao visivel")
