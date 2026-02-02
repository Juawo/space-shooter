extends "res://scripts/game/enemies/enemie_base.gd"

@export var bullet_scene : PackedScene = preload("res://scenes/game/enemies/enemie4/enemy_rotated_bullet.tscn")
@onready var left_gun_point: Marker2D = $GunPoints/LeftGunPoint
@onready var middle_gun_point: Marker2D = $GunPoints/MiddleGunPoint
@onready var right_gun_point: Marker2D = $GunPoints/RightGunPoint

func shoot():
	if bullet_scene:
		# Feio pq so queria que funcionasse
		var bullet_left = bullet_scene.instantiate()
		var bullet_middle = bullet_scene.instantiate()
		var bullet_right = bullet_scene.instantiate()
		
		bullet_left.global_position = left_gun_point.global_position
		bullet_middle.global_position = middle_gun_point.global_position
		bullet_right.global_position = right_gun_point.global_position
		
		bullet_left.rotation = left_gun_point.rotation
		bullet_middle.rotation = middle_gun_point.rotation
		bullet_right.rotation = right_gun_point.rotation
		
		get_tree().current_scene.add_child(bullet_left)
		get_tree().current_scene.add_child(bullet_middle)
		get_tree().current_scene.add_child(bullet_right)

# Apenas para teste
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		shoot()
