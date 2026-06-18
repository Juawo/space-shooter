extends Area2D

@export var fall_speed := 250.0 # Velocidade de descida do item

func _process(delta: float) -> void:
	# Faz o item descer verticalmente pela tela
	position.y += fall_speed * delta

func _on_body_entered(body: Node2D) -> void:
	# Verifica se quem coletou foi o Player
	if body.is_in_group("Player") or body.name == "Player":
		if body.has_method("activate_shield"):
			body.activate_shield()
			queue_free() # Remove o item coletado da tela

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Limpa a memória caso o jogador perca o item e ele saia da tela
	queue_free()
