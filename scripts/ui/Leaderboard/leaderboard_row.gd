extends Control

@export var rank_pos : String
@export var nickname : String
@export var high_score : int
@export var base_color : Color

@onready var rank_label: Label = $MarginContainer/HBoxContainer/rank_label
@onready var nickname_label: Label = $MarginContainer/HBoxContainer/nickname_label
@onready var high_score_label: Label = $MarginContainer/HBoxContainer/high_score_label

func populate(data : Object) :
	rank_label.text = rank_text(data.rank)
	#rank_label.theme_override_colors.font_color = base_color
	
	nickname_label.text = str(data.player.name)
	#nickname_label.theme_override_colors.font_color = base_color

	high_score_label.text = str(int(data.score))
	#high_score_label.theme_override_colors.font_color = base_color

func rank_text(rank : int) -> String:
	match rank:
		1 : 
			return str(rank) + "st"
		2 : 
			return str(rank) + "nd"
		3 : 
			return str(rank) + "rd"
		_: 
			return str(rank) + "th"
