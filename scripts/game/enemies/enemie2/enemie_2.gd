extends "res://scripts/game/enemies/enemie_base.gd"

@export var bullet_scene : PackedScene = preload("res://scenes/game/enemies/enemy_bullet.tscn")
@onready var gun_point: Marker2D = $GunPoint

func shoot():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = gun_point.global_position
		get_tree().current_scene.add_child(bullet)
