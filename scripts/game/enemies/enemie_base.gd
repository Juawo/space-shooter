extends Area2D

signal enemy_died

var power_up_scene := preload("res://scenes/game/upgrades/cadence.tscn")
var shield_power_up_scene := preload("res://scenes/game/upgrades/shield-drop.tscn") # Caminho da sua cena de escudo
@export_range(1, 4) var enemy_level := 1 # Nível de dificuldade (1 a 4)

@export var life := 1
@export var SPEED := 140
@export var score_value := 10
@export var can_shoot := false
@export var base_color := Color.CHARTREUSE

@onready var particle_die: CPUParticles2D = $ParticleDie
@onready var shoot_timer: Timer = $ShootTimer
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var animated_sprite : AnimatedSprite2D = null

var is_dead : bool = false


func _enter_tree() -> void:
	GameEvents.enemy_spawned .emit()

func _ready() -> void:
	if can_shoot:
		shoot_timer.start(randf_range(1.5,3.0))
		shoot_timer.wait_time = randf_range(1.5,3.0)
	else :
		shoot_timer.queue_free()
	

func _process(delta: float) -> void:
	position.y += SPEED * delta

func takeDamage(damage_value: int) -> void:
	if is_dead : 
		return
		
	if life > 1 :
		SoundManager.play_impact()
	life -= damage_value
	if(life <= 0):
		die()

func dieTween() -> Tween:
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	var target_scale = scale - Vector2(0.4,0.4)
	tween.tween_property(self, "scale", target_scale, 0.4)
	return tween

func die():
	if is_dead : 
		return
	is_dead = true
	
	GameEvents.enemy_died.emit(score_value)
	
	check_drop_chance()
	
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	if can_shoot and is_instance_valid(shoot_timer):
		shoot_timer.stop()
	
	await dieTween().finished
	
	if animated_sprite != null :
		animated_sprite.visible = false
		animated_sprite.stop()
	
	sprite_2d.visible = false
	particle_die.color = base_color
	
	particle_die.emitting = true
	SoundManager.play_explosion()
	
	await particle_die.finished 
	enemy_died.emit()
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if(area.is_in_group("PlayerProjectiles")):
		takeDamage(area.damage_value)
		area.queue_free()

func shoot():
	# logica de disparo, implementado nas scenes filhos
	pass

func _on_shoot_timer_timeout() -> void:
	shoot()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	GameEvents.enemy_escaped.emit()
	queue_free()

func check_drop_chance():
	var base_chance = 10
	var level_bonus = enemy_level * 5
	var drop_probability = base_chance + level_bonus
	
	if randf() <= (drop_probability / 100.0):
		spawn_random_power_up()
		
func spawn_random_power_up():
	var available_drops = [power_up_scene, shield_power_up_scene]
	
	var chosen_scene = available_drops[randi() % available_drops.size()]
	
	if chosen_scene:
		var p_up = chosen_scene.instantiate()
		p_up.global_position = global_position
		get_tree().current_scene.add_child(p_up)
