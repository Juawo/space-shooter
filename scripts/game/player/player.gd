extends CharacterBody2D

signal life_change(life_value)

@export var bullet_scene := preload("res://scenes/game/player/player_bullet.tscn")
@onready var marker_2d: Marker2D = $Marker2D

var original_shoot_wait_time : float = 0.0
var boost_timer : SceneTreeTimer = null
@onready var muzzle_flash_animation: AnimatedSprite2D = $muzzle_flash_animation

@export var SPEED := 100.0
@export var SMOOTH_SPEED := 0.1
@export var DEADZONE = 0.3 
@export var shoot_speed_modifier := 1.0

@onready var screen_size = get_viewport_rect().size
@onready var sprite: Sprite2D = $Sprite
@onready var invecible_timer: Timer = $InvecibleTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var accel_pos : Vector3
var is_invecible : bool = false

# Alterado para Vector2 para limitar a nave corretamente nas bordas (X e Y)
@export var player_margins := Vector2(54.0, 54.0) 

var shield_timer : SceneTreeTimer = null
var is_shield_active : bool = false

@onready var shield_node : Node2D = $Shield

var playerLife := 3 :
	set (new_value) :
		playerLife = new_value
		life_change.emit(new_value)
		if new_value == 0:
			GameEvents.game_over.emit()


func _physics_process(delta: float) -> void:
	var target_velocity = Vector2.ZERO
	var sense_multiplier = SaveManager.sensibility / 100.0
	
	if SaveManager.control_mode == 0:
		# --- LÓGICA DE INCLINAÇÃO (TILT) 2D ---
		accel_pos = Input.get_accelerometer()
		
		# No acelerômetro, X costuma ser horizontal e Y vertical (pode variar conforme a orientação do projeto)
		var input_direction = Vector2(accel_pos.x, -accel_pos.y) 
		
		# Fallback para Teclado (Setas / WASD)
		if input_direction == Vector2.ZERO:
			input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * 5.0
			
		target_velocity = input_direction * SPEED * sense_multiplier
		
		if input_direction.length() > DEADZONE:
			var weight = clamp(SMOOTH_SPEED * sense_multiplier, 0.01, 0.9)
			velocity = velocity.lerp(target_velocity, weight)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, SPEED * delta)
			
	else:
		# --- LÓGICA DE TOQUE (TOUCH) LIVRE 2D ---
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var mouse_pos = get_viewport().get_mouse_position()
			# Calculamos o vetor de distância (X e Y) até o dedo/mouse
			var distance_vector = mouse_pos - global_position
			
			# 1. Zona Morta: Se estiver muito perto do dedo (menos de 2 pixels), para.
			if distance_vector.length() < 2.0:
				velocity = velocity.move_toward(Vector2.ZERO, SPEED * delta * 20)
			else:
				# 2. Cálculo da Velocidade Alvo Baseada na Distância (Smooth Out)
				var desired_speed = clamp(distance_vector.length() * 10.0, 0, SPEED * 6.0)
				target_velocity = distance_vector.normalized() * desired_speed * sense_multiplier
				
				# 3. Interpolação de Velocidade 2D
				var weight = 0.15 * sense_multiplier
				velocity = velocity.lerp(target_velocity, clamp(weight, 0, 1))
		else:
			# Desaceleração rápida ao soltar o dedo
			velocity = velocity.move_toward(Vector2.ZERO, SPEED * delta * 10)
			
	move_and_slide()
	
	# --- CLAMP (Limitar a nave dentro da tela em X e Y) ---
	position.x = clamp(position.x, player_margins.x, screen_size.x - player_margins.x)
	position.y = clamp(position.y, player_margins.y, screen_size.y - player_margins.y)


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
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	await invecible_timer.timeout
	tween.kill()
	modulate.a = 1.0
	is_invecible = false

func takeDamage (amount : int):
	if is_shield_active:
		return
		
	if is_invecible:
		return
		
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
			
		get_tree().current_scene.add_child(bullet)
		await muzzle_flash_animation.animation_finished
		muzzle_flash_animation.visible = false

func _on_invecible_timer_timeout() -> void:
	is_invecible = false

func apply_speed_boost(multiplier: float) -> void:
	if boost_timer == null:
		original_shoot_wait_time = $ShootTimer.wait_time
		$ShootTimer.wait_time = original_shoot_wait_time / multiplier
	
	var current_timer = get_tree().create_timer(10.0)
	boost_timer = current_timer
	
	await current_timer.timeout
	
	if boost_timer == current_timer:
		$ShootTimer.wait_time = original_shoot_wait_time
		boost_timer = null

# Variável de controle para o Tween do escudo (evita conflitos se pegar outro escudo enquanto pisca)
var shield_tween: Tween = null

func activate_shield() -> void:
	# 1. Se o escudo não estava ativo, liga o visual e a propriedade
	if shield_timer == null:
		is_shield_active = true
		shield_node.visible = true
		shield_node.modulate.a = 1.0 # Garante que a opacidade comece em 100%
	
	# Se o escudo já estava piscando de um item anterior, para o piscar e reseta a opacidade
	if shield_tween and shield_tween.is_valid():
		shield_tween.kill()
		shield_node.modulate.a = 1.0

	# 2. Cria o timer total de 10 segundos
	var current_shield_timer = get_tree().create_timer(10.0)
	shield_timer = current_shield_timer
	
	# Espera os primeiros 7 segundos (10s no total - 3s de aviso)
	await get_tree().create_timer(7.0).timeout
	
	# Verificação de segurança: Só começa a piscar se o jogador NÃO pegou outro escudo nesse meio tempo
	if shield_timer == current_shield_timer:
		BlinkShieldTween()

	# Espera os 3 segundos finais para acabar o tempo total
	await current_shield_timer.timeout
	
	# 3. Verificação de Segurança Final: Desliga tudo apenas se este timer for o último ativo
	if shield_timer == current_shield_timer:
		is_shield_active = false
		shield_node.visible = false
		shield_timer = null
		if shield_tween and shield_tween.is_valid():
			shield_tween.kill()

# Função auxiliar para fazer o escudo piscar nos 3 segundos finais
func BlinkShieldTween() -> void:
	shield_tween = create_tween()
	shield_tween.set_loops() # Fica repetindo em loop até ser parado pelo .kill()
	shield_tween.tween_property(shield_node, "modulate:a", 0.2, 0.15) # Vai para 20% de opacidade em 0.15s
	shield_tween.tween_property(shield_node, "modulate:a", 1.0, 0.15) # Volta para 100% de opacidade em 0.15s
