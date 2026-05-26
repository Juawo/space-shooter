extends "res://scripts/game/enemies/enemie_base.gd"

@onready var sprite: Sprite2D = $Sprite2D
var ENEMIE_1_VARIANT_1 := preload("res://assets/sprites/enemies/enemie_1_variant_1.png")
var ENEMIE_1_VARIANT_2 := preload("res://assets/sprites/enemies/enemie_1_variant_2.png")
var ENEMIE_1_VARIANT_3 := preload("res://assets/sprites/enemies/enemie_1_variant_3.png")


func _ready() -> void:
	var variations = [ENEMIE_1_VARIANT_1,ENEMIE_1_VARIANT_2,ENEMIE_1_VARIANT_3 ]
	var sorted_variation = variations[randi() % variations.size()]
	
	if sorted_variation == ENEMIE_1_VARIANT_1 :
		base_color = Color.DARK_OLIVE_GREEN
	elif sorted_variation == ENEMIE_1_VARIANT_2:
		base_color = Color.ROYAL_BLUE
	else :
		base_color = Color.WHITE
		
	sprite.texture = sorted_variation
