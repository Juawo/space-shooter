extends Control

@onready var logo: TextureRect = $TextureRect

# Caminho para a sua cena de boot (onde ocorre a checagem de internet/registro)
var boot_scene_path : String = "res://scenes/ui/boot_scene/boot_scene.tscn"


func _ready() -> void:
	# Garante que o jogo comece com a logo invisível
	logo.modulate.a = 0.0
	start_splash_animation()

func start_splash_animation() -> void:
	var tween = create_tween()
	
	# 1. Fade-in da logo (Leva 1.2 segundos para aparecer totalmente)
	tween.tween_property(logo, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# 2. Tempo de exposição (Fica estático na tela por 1.5 segundos)
	tween.tween_interval(1)
	
	# 3. Fade-out da logo (Leva 1.0 segundo para sumir)
	tween.tween_property(logo, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# 4. Quando toda a sequência de animação terminar, muda de cena
	tween.finished.connect(_on_splash_finished)

func _on_splash_finished() -> void:
	get_tree().change_scene_to_file(boot_scene_path)
