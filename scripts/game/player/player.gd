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
var half_width := 54.0 # (tamanho_do_sprite * scale)/2

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
	var target_velocity = 0.0
	# Normalizamos a sensibilidade (ex: 100 vira 1.0, 50 vira 0.5, 200 vira 2.0)
	var sense_multiplier = SaveManager.sensibility / 100.0
	
	if SaveManager.control_mode == 0:
		# --- LÓGICA DE INCLINAÇÃO (TILT) ---
		accel_pos = Input.get_accelerometer()
		var input_x = accel_pos.x
		
		# Fallback para setas (Teclado)
		if input_x == 0:
			input_x = Input.get_axis("ui_left", "ui_right") * 5.0
			
		# Aplicamos a sensibilidade no target_velocity
		target_velocity = input_x * SPEED * sense_multiplier
		
		if abs(input_x) > DEADZONE:
			# Também podemos usar a sensibilidade para tornar o lerp mais responsivo
			var weight = clamp(SMOOTH_SPEED * sense_multiplier, 0.01, 0.9)
			velocity.x = lerp(velocity.x, target_velocity, weight)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
			
	else:
		# --- LÓGICA DE TOQUE (TOUCH) ULTRA SUAVE ---
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var mouse_x = get_viewport().get_mouse_position().x
			var distance = mouse_x - global_position.x
			
			# 1. Zona Morta (Essential): Se estiver a menos de 2px, a nave já chegou.
			if abs(distance) < 2.0:
				velocity.x = move_toward(velocity.x, 0, SPEED * delta * 20)
			else:
				# 2. Cálculo da Velocidade Alvo
				# Usamos uma curva para a nave desacelerar conforme chega perto (Smooth Out)
				var desired_speed = clamp(abs(distance) * 10.0, 0, SPEED * 6.0)
				target_velocity = sign(distance) * desired_speed * sense_multiplier
				
				# 3. Interpolação de Velocidade (Peso menor = mais suave)
				var weight = 0.15 * sense_multiplier
				velocity.x = lerp(velocity.x, target_velocity, clamp(weight, 0, 1))
		else:
			# Desaceleração rápida ao soltar o dedo
			velocity.x = move_toward(velocity.x, 0, SPEED * delta * 10)
	move_and_slide()
	
	# Clamp (Limitar a nave dentro da tela)
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
	# Se o escudo estiver ativo, o dano é completamente bloqueado!
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
		
		# Aplicamos o modificador na bala antes de adicionar na cena
		if "bullet_speed" in bullet:
			bullet.bullet_speed *= shoot_speed_modifier
			
		get_tree().current_scene.add_child(bullet)
		await muzzle_flash_animation.animation_finished
		muzzle_flash_animation.visible = false

func _on_invecible_timer_timeout() -> void:
	is_invecible = false

# Função para ativar o boost
# --- Substitua sua função apply_speed_boost por esta ---
func apply_speed_boost(multiplier: float) -> void:
	# 1. Se o efeito NÃO está ativo, guarda o tempo original e aplica o boost [cite: 63]
	if boost_timer == null:
		original_shoot_wait_time = $ShootTimer.wait_time
		$ShootTimer.wait_time = original_shoot_wait_time / multiplier # [cite: 63]
	
	# 2. Registra um novo Timer de 10 segundos 
	# Ao reatribuir a variável, perdemos a referência ao "await" anterior, 
	# mas precisamos garantir que apenas o último reset o valor original.
	var current_timer = get_tree().create_timer(10.0)
	boost_timer = current_timer
	
	await current_timer.timeout
	
	# 3. Verificação de Segurança: 
	# Só reseta se este timer específico for o último que o jogador coletou
	if boost_timer == current_timer:
		$ShootTimer.wait_time = original_shoot_wait_time
		boost_timer = null # Limpa a referência para permitir novos boosts

func activate_shield() -> void:
	# 1. Se o escudo não estava ativo, liga o visual e a propriedade
	if shield_timer == null:
		is_shield_active = true
		shield_node.visible = true
		# Opcional: Se o seu escudo for um AnimatedSprite, você pode dar shield_node.play() aqui
	
	# 2. Cria/reseta o timer seguro de 10 segundos 
	var current_shield_timer = get_tree().create_timer(10.0)
	shield_timer = current_shield_timer
	
	await current_shield_timer.timeout
	
	# 3. Verificação de Segurança (Igual ao do Speed Boost): 
	# Só desliga se este timer for o último escudo que o jogador coletou 
	if shield_timer == current_shield_timer:
		is_shield_active = false
		shield_node.visible = false
		shield_timer = null
