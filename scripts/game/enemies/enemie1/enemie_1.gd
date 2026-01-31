extends "res://scripts/game/enemies/enemie_base.gd"

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		die()
