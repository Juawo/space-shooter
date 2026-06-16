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
		# LÓGICA DE INCLINAÇÃO (TILT) PARIFICADA
		accel_pos = Input.get_accelerometer()
		# Criamos um vetor bruto com os dados do sensor
		var raw_tilt = Vector2(accel_pos.x, -accel_pos.y)
		
		# Fallback para Teclado (Setas / WASD no PC/Editor)
		var keyboard_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		if keyboard_input != Vector2.ZERO:
			# No PC, vai usar a velocidade máxima parificada com o toque (Multiplicado por 6.0 ou 8.0)
			velocity = keyboard_input * SPEED * 6.0
		else:
			# No Celular: Se o movimento passar da zona morta física do sensor
			if raw_tilt.length() > DEADZONE:
				
				# 🌟 O PULO DO GATO: O OFFSET DE INCLINAÇÃO
				# Quando o celular está em pé na sua mão, o accel_pos.y costuma marcar entre 4.0 e 6.0.
				# Nós subtraímos esse valor para fazer com que a sua postura confortável seja o "ZERO" da nave!
				# Mude o '5.0' abaixo para calibrar o ponto neutro ideal para as suas mãos.
				
				const TILT_OFFSET_Y : float = 7.0
				var calibrated_y : float = -accel_pos.y - TILT_OFFSET_Y
				
				# Agora montamos o vetor com os eixos corrigidos e os multiplicadores de força
				var balanced_tilt = Vector2(
					raw_tilt.x * 1.2,   # Esquerda/Direita continua normal
					calibrated_y * 3.0  # Cima/Baixo calibrado com o ponto neutro e o boost de força
				)
				
				# Daqui para baixo continua a sua lógica perfeita de velocidade e LERP
				var calculated_speed = clamp(balanced_tilt.length() * SPEED, 0, SPEED * 5.0)
				target_velocity = balanced_tilt.normalized() * calculated_speed * sense_multiplier
				
				var weight = 0.25 * sense_multiplier
				velocity = velocity.lerp(target_velocity, clamp(weight, 0.01, 1.0))
			else:
				velocity = velocity.move_toward(Vector2.ZERO, SPEED * delta * 8)
	else:
		# LÓGICA DE TOQUE (TOUCH)
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var mouse_pos = get_viewport().get_mouse_position()
			var distance_vector = mouse_pos - global_position
			
			if distance_vector.length() < 2.0:
				velocity = velocity.move_toward(Vector2.ZERO, SPEED * delta * 20)
			else:
				# Deixei o limite em 6.0 também para equiparar perfeitamente com a inclinação acima
				var desired_speed = clamp(distance_vector.length() * 12.0, 0, SPEED * 6.0)
				target_velocity = distance_vector.normalized() * desired_speed * sense_multiplier
				
				var weight = 0.40 * sense_multiplier
				velocity = velocity.lerp(target_velocity, clamp(weight, 0, 1))
		else:
			velocity = velocity.move_toward(Vector2.ZERO, SPEED * delta * 12)
			
	# Aplica o movimento final
	move_and_slide()
	
	# ─── 📐 LIMITADOR DE TELA ───
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
