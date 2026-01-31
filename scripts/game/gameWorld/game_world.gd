extends Node2D

@onready var accel_data: Label = $AccelData
@onready var player: CharacterBody2D = $Player
var accel_pos
 
func _process(_delta: float) -> void:
	accel_pos = player.accel_pos 
	accel_data.text = "X: %.2f , Y: %.2f , Z: %.2f" % [accel_pos.x, accel_pos.y, accel_pos.z]
