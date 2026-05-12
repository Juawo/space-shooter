extends Node2D

#@export var scroll_speed: float = 150.0
#
#func _process(delta: float) -> void:
	## Iteramos por todos os filhos do Node2D
	#for child in get_children():
		#if child is Parallax2D:
			## Movemos o offset individual de cada camada
			## O sistema Parallax2D já aplica o 'Factor' automaticamente
			#child.scroll_offset.y += scroll_speed * delta
