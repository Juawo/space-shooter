extends CharacterBody2D

signal life_change(life_value)

@export var bullet_scene := preload("res://scenes/game/player/player_bullet.tscn")
@onready var marker_2d: Marker2D = $Marker2D

@export var SPEED := 100.0
@export var SMOOTH_SPEED := 0.1
@export var DEADZONE = 0.3

@onready var screen_size = get_viewport_rect().size
@onready var sprite: Sprite2D = $Sprite
@onready var invecible_timer: Timer = $InvecibleTimer

var accel_pos : Vector3
var is_invecible : bool = false

var playerLife := 3 :
	set (new_value) :
		playerLife = new_value
		life_change.emit(new_value)
		if new_value == 0:
			GameEvents.game_over.emit()

func _physics_process(delta: float) -> void:
	# TODO : Pegar os dados do acelerometro
	# TODO : Com base nos dados, pegar a direction (left | right)
	# TODO : Com base na direction deslocar o player com base na SPEED

	accel_pos = Input.get_accelerometer()
	
	var input_x = accel_pos.x
	if input_x == 0:
		input_x = Input.get_axis("ui_left", "ui_right") * 5.0
		
	var target_velocity = input_x  * SPEED
	
	if(abs(input_x) > DEADZONE):
		velocity.x = lerp(velocity.x, target_velocity, SMOOTH_SPEED)
	else :
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)

	move_and_slide()
	var half_width = (sprite.get_rect().size.x * sprite.scale.x) / 2 
	position.x = clamp(position.x, half_width, screen_size.x - half_width)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies") or area.is_in_group("EnemiesProjectiles"):
		var damage = area.damage_value if "damage_value" in area else 1
		takeDamage(damage)
		if area.is_in_group("EnemiesProjectiles"):
			area.queue_free()
		else :
			area.die()

func DamageTween() :
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "modulate:a", 0.0, 0.1) # a = alpha (transparência)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	await invecible_timer.timeout
	tween.kill()
	modulate.a = 1.0
	is_invecible = false

func takeDamage (amount : int):
	if is_invecible:
		return
		
	playerLife = clamp(playerLife - amount, 0, 3)
	
	is_invecible = true
	invecible_timer.start(1.0)
	DamageTween()
	

func _on_shoot_timer_timeout() -> void:
	shoot()

func shoot () -> void:
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = marker_2d.global_position
		get_tree().current_scene.add_child(bullet)


func _on_invecible_timer_timeout() -> void:
	is_invecible = false
