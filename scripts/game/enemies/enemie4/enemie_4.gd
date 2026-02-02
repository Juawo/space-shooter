extends "res://scripts/game/enemies/enemie_base.gd"

@export var bullet_scene : PackedScene = preload("res://scenes/game/enemies/enemie4/enemy_rotated_bullet.tscn")
@onready var gun_points: Node2D = $GunPoints

func shoot():
	if bullet_scene:
		for gun_point in gun_points.get_children():
			var bullet = bullet_scene.instantiate()
			bullet.global_position = gun_point.global_position
			bullet.rotation = gun_point.rotation
			get_tree().current_scene.add_child(bullet)
