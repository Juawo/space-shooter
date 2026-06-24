extends "res://scripts/game/enemies/enemie_base.gd"

@export var bullet_scene : PackedScene = preload("res://scenes/game/enemies/enemie4/enemy_rotated_bullet.tscn")
@onready var gun_points: Node2D = $GunPoints
const ENEMIE_4_IDLE_DESTROYED = preload("uid://b6ytekojsomed")
var components_broken = true
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle_flash: AnimatedSprite2D = $muzzle_flash
 
func shoot():
	if bullet_scene:
		sprite_2d.visible = false
		animated_sprite_2d.visible = true
		animated_sprite_2d.play("prepare_bullet")
		await animated_sprite_2d.animation_finished
		muzzle_flash.visible = true
		muzzle_flash.play("show_muzzle")
		for gun_point in gun_points.get_children():
			var bullet = bullet_scene.instantiate()
			bullet.global_position = gun_point.global_position
			bullet.rotation = gun_point.rotation
			get_tree().current_scene.add_child(bullet)
		await muzzle_flash.animation_finished
		muzzle_flash.visible = true
		animated_sprite_2d.visible = false
		sprite_2d.visible = true

func break_cannons():
	components_broken = true
	can_shoot = false
	
	if is_instance_valid(shoot_timer):
		shoot_timer.stop()
	
	sprite_2d.texture = ENEMIE_4_IDLE_DESTROYED
	
	var tween = create_tween()
	sprite_2d.modulate = Color.RED 
	tween.tween_property(sprite_2d, "modulate", Color.WHITE, 0.15)

func takeDamage(damage_value: int) -> void:
	life -= damage_value
	if life == 1 :
		break_cannons()
	if(life <= 0):
		die()
