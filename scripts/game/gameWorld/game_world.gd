extends Node2D

@onready var hud: Control = $Hud
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	player.life_change.connect(hud.update_life)
