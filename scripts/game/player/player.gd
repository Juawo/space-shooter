extends CharacterBody2D

signal gameOver

@export var SPEED := 200.0
@export var SMOOTH_SPEED := 0.1
@export var DEADZONE = 0.3
@onready var screen_size = get_viewport_rect().size
@onready var sprite: Sprite2D = $Sprite

@export var accel_pos : Vector3

var playerLife := 3 :
	set (new_value) :
		playerLife = new_value
		if new_value == 0:
			gameOver.emit()


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


func _on_area_2d_area_entered(_area: Area2D) -> void:
	takeDamage()
	
func takeDamage ():
	if playerLife > 0:
		playerLife -= 1
	else :
		gameOver.emit()
