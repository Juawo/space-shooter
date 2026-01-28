extends CharacterBody2D

signal gameOver

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var playerLife := 3 :
	set (new_value) :
		playerLife = new_value
		if new_value == 0:
			gameOver.emit()


func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _on_area_2d_area_entered(area: Area2D) -> void:
	takeDamage()
	
func takeDamage ():
	if playerLife > 0:
		playerLife - 1
	else :
		gameOver.emit()
