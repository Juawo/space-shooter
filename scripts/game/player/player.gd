extends CharacterBody2D

signal life_change(life_value)

@export var SPEED := 100.0
@export var SMOOTH_SPEED := 0.1
@export var DEADZONE = 0.3 
@export var shoot_speed_modifier := 1.0
@export var player_margins := Vector2(54.0, 54.0) 
@export var bullet_scene := preload("res://scenes/game/player/player_bullet.tscn")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle_flash_animation: AnimatedSprite2D = $muzzle_flash_animation
@onready var marker_2d: Marker2D = $Marker2D
@onready var sprite: Sprite2D = $Sprite
@onready var shield_node : Node2D = $Shield

@onready var screen_size = get_viewport_rect().size
@onready var invecible_timer: Timer = $InvecibleTimer

@onready var cadence_timer: Timer = $CadenceTimer
@onready var cadence_warning_timer: Timer = $CadenceWarningTimer
@onready var shield_timer: Timer = $ShieldTimer
@onready var shield_warning_timer: Timer = $ShieldWarningTimer
@onready var shoot_timer: Timer = $ShootTimer

var is_touching : bool
var touch_position : Vector2 = Vector2.ZERO
var accel_pos : Vector3

var is_invecible : bool = false
var is_shield_active : bool = false
var is_cadence_active: bool = false
var shield_tween : Tween = null
var invecible_tween : Tween = null
var original_shoot_wait_time : float = 0.0

var playerLife := 3 :
	set (new_value) :
		playerLife = new_value
		life_change.emit(new_value)
		if playerLife == 1 :
			SoundManager.play_life_alarm()
		if new_value <= 0:
			GameEvents.game_over.emit()
			SoundManager.play_explosion()

func _ready() -> void:
	original_shoot_wait_time = shoot_timer.wait_time

func _unhandled_input(event: InputEvent) -> void:
	if SaveManager.control_mode != 1:
		return
		
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.is_pressed():
			is_touching = true
			touch_position = event.position
		else:
			is_touching = false
			
	elif event is InputEventScreenDrag or event is InputEventMouseMotion:
		if is_touching:
			touch_position = event.position

func _physics_process(delta: float) -> void:
	var sense_multiplier = SaveManager.sensibility / 100.0
	
	if SaveManager.control_mode == 0:
		_handle_accelerometer_movement(delta, sense_multiplier)
	else:
		_handle_touch_movement(delta, sense_multiplier)
		
	move_and_slide()
	
	position.x = clamp(position.x, player_margins.x, screen_size.x - player_margins.x)
	position.y = clamp(position.y, player_margins.y, screen_size.y - player_margins.y)

func _handle_accelerometer_movement(delta: float, sense_multiplier: float) -> void:
	var target_velocity = Vector2.ZERO
	accel_pos = Input.get_accelerometer()
	
	var raw_tilt = Vector2(accel_pos.x, -accel_pos.y)
	var keyboard_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if keyboard_input != Vector2.ZERO:
		velocity = keyboard_input * SPEED * 6.0
	else:
		if raw_tilt.length() > DEADZONE:
			const TILT_OFFSET_Y : float = 7.0
			var calibrated_y : float = -accel_pos.y - TILT_OFFSET_Y
			
			var balanced_tilt = Vector2(raw_tilt.x * 1.2, calibrated_y * 3.0)
			var calculated_speed = clamp(balanced_tilt.length() * SPEED, 0, SPEED * 5.0)
			
			target_velocity = balanced_tilt.normalized() * calculated_speed * sense_multiplier
			var weight = 0.25 * sense_multiplier
			velocity = velocity.lerp(target_velocity, clamp(weight, 0.01, 1.0))
		else:
			velocity = velocity.move_toward(Vector2.ZERO, SPEED * delta * 8)

func _handle_touch_movement(delta: float, sense_multiplier: float) -> void:
	if is_touching:
		var distance_vector = touch_position - global_position
		
		if distance_vector.length() < 2.0:
			velocity = velocity.move_toward(Vector2.ZERO, SPEED * delta * 20)
		else:
			var desired_speed = clamp(distance_vector.length() * 12.0, 0, SPEED * 6.0)
			var target_velocity = distance_vector.normalized() * desired_speed * sense_multiplier
			
			var weight = 0.40 * sense_multiplier
			velocity = velocity.lerp(target_velocity, clamp(weight, 0, 1))
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED * delta * 12)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies") or area.is_in_group("EnemiesProjectiles"):
		var damage = area.damage_value if "damage_value" in area else 1
		if area.has_method("explode"):
			area.explode()
		takeDamage(damage)
		if area.is_in_group("EnemiesProjectiles"):
			area.queue_free()
		else :
			area.die()

func DamageTween() :
	invecible_tween = create_tween()
	invecible_tween.set_loops()
	invecible_tween.tween_property(self, "modulate:a", 0.0, 0.1)
	invecible_tween.tween_property(self, "modulate:a", 1.0, 0.1)

func takeDamage (amount : int):
	if is_shield_active:
		return
		
	if is_invecible:
		return
	SoundManager.play_impact()
	playerLife = clamp(playerLife - amount, 0, 3)
	is_invecible = true
	invecible_timer.start(1.0)
	DamageTween()

func _on_shoot_timer_timeout() -> void:
	shoot()

func shoot() -> void:
	if bullet_scene:
		muzzle_flash_animation.visible = true
		muzzle_flash_animation.play("muzzle_flash")
		var bullet = bullet_scene.instantiate()
		bullet.global_position = marker_2d.global_position
		
		if "bullet_speed" in bullet:
			bullet.bullet_speed *= shoot_speed_modifier
		SoundManager.play_dispare_player()
		get_tree().current_scene.add_child(bullet)
		await muzzle_flash_animation.animation_finished
		muzzle_flash_animation.visible = false

func _on_invecible_timer_timeout() -> void:
	is_invecible = false
	invecible_tween.kill()
	modulate.a = 1.0
	is_invecible = false

func apply_speed_boost(multiplier: float) -> void:
	if not is_cadence_active:
		shoot_timer.wait_time = original_shoot_wait_time / multiplier
		is_cadence_active = true
	cadence_timer.start(10.0)
	cadence_warning_timer.start(7.67) # cadence time - warning sound time

func _on_cadence_warning_timer_timeout() -> void:
	SoundManager.play_powerup_finishing()

func _on_cadence_timer_timeout() -> void:
	shoot_timer.wait_time = original_shoot_wait_time
	is_cadence_active = false

func activate_shield() -> void:
	is_shield_active = true
	shield_node.visible = true
	shield_node.modulate.a = 1.0
	
	if shield_tween and shield_tween.is_valid():
		shield_tween.kill()
	
	shield_timer.start(10.0)
	shield_warning_timer.start(8.0)

func BlinkShieldTween() -> void:
	shield_tween = create_tween()
	shield_tween.set_loops()
	shield_tween.tween_property(shield_node, "modulate:a", 0.2, 0.15) # Vai para 20% de opacidade em 0.15s
	shield_tween.tween_property(shield_node, "modulate:a", 1.0, 0.15) # Volta para 100% de opacidade em 0.15s

func _on_shield_warning_timer_timeout() -> void:
	SoundManager.play_powerup_finishing()
	BlinkShieldTween()

func _on_shield_timer_timeout() -> void:
	is_shield_active = false
	shield_node.visible = false
	if shield_tween and shield_tween.is_valid():
		shield_tween.kill()

func remove_powerups() -> void:
	cadence_timer.stop()
	cadence_warning_timer.stop()
	if is_cadence_active:
		shoot_timer.wait_time = original_shoot_wait_time
		is_cadence_active = false
	
	shield_timer.stop()
	shield_warning_timer.stop()
	is_shield_active = false
	
	if shield_node:
		shield_node.visible = false
		shield_node.modulate.a = 1.0
		
	if shield_tween and shield_tween.is_valid():
		shield_tween.kill()
	
	if invecible_tween and invecible_tween.is_valid():
		invecible_tween.kill()

	is_invecible = false
	invecible_timer.stop()
	modulate.a = 1.0
