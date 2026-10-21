extends "res://scripts/game/enemies/enemie_base.gd"

@export var bullet_scene : PackedScene = preload("uid://cnsd0d5d07i4y")
@onready var gun_point: Marker2D = $GunPoint
@onready var sprite_animation: AnimatedSprite2D = $sprite_animation
@onready var muzzle_flash_animation: AnimatedSprite2D = $muzzle_flash_animation
var is_charged := false

func _ready() -> void:
	super._ready()
	sprite_animation.play("fill")
	sprite_animation.animation_finished.connect(_on_sprite_animation_finished)
	muzzle_flash_animation.animation_finished.connect(_on_muzzle_flash_finish)


func _on_muzzle_flash_finish() -> void :
	muzzle_flash_animation.visible = false

func shoot():
	if is_dead :
		return
	if is_charged :
		is_charged = false
		shoot_timer.paused = true
		sprite_animation.play("prepare_bullet")

func _on_sprite_animation_finished() -> void :
	if is_dead:
		return
	if sprite_animation.animation == "prepare_bullet" :
		instantiate_projectile()
		SoundManager.play_dispare_plasma()
		muzzle_flash_animation.visible = true
		muzzle_flash_animation.play("show_muzzle")
		sprite_animation.play("fill")
		shoot_timer.paused = false
		
	elif sprite_animation.animation == "fill":
		is_charged = true
		if is_instance_valid(shoot_timer):
			shoot_timer.paused = false
			shoot_timer.start(randf_range(0.3, 1))

func instantiate_projectile() -> void :
	if is_dead :
		return
	
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		muzzle_flash_animation.visible = true
		muzzle_flash_animation.play("show_muzzle")
		bullet.global_position = gun_point.global_position
		get_tree().current_scene.add_child(bullet)
